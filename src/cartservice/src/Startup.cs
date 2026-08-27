using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Hosting;
using cartservice.cartstore;
using cartservice.services;
using Microsoft.Extensions.Caching.StackExchangeRedis;
using StackExchange.Redis;

namespace cartservice
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }
        
        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
            string redisAddress = Configuration["REDIS_ADDR"];
            string spannerProjectId = Configuration["SPANNER_PROJECT"];
            string spannerConnectionString = Configuration["SPANNER_CONNECTION_STRING"];
            string alloyDBConnectionString = Configuration["ALLOYDB_PRIMARY_IP"];

            if (!string.IsNullOrEmpty(redisAddress))
            {
                services.AddStackExchangeRedisCache(options =>
                {
                    if (TryParseRedisUrl(redisAddress, out ConfigurationOptions parsed))
                    {
                        options.ConfigurationOptions = parsed;
                    }
                    else
                    {
                        options.Configuration = redisAddress;
                    }
                });
                services.AddSingleton<ICartStore, RedisCartStore>();
            }
            else if (!string.IsNullOrEmpty(spannerProjectId) || !string.IsNullOrEmpty(spannerConnectionString))
            {
                services.AddSingleton<ICartStore, SpannerCartStore>();
            }
            else if (!string.IsNullOrEmpty(alloyDBConnectionString))
            {
                Console.WriteLine("Creating AlloyDB cart store");
                services.AddSingleton<ICartStore, AlloyDBCartStore>();
            }
            else
            {
                Console.WriteLine("Redis cache host(hostname+port) was not specified. Starting a cart service using in memory store");
                services.AddDistributedMemoryCache();
                services.AddSingleton<ICartStore, RedisCartStore>();
            }


            services.AddGrpc();
        }

        // REDIS_ADDR is normally a StackExchange.Redis configuration string such as
        // "host:port,password=...,ssl=True". Managed Redis offerings instead hand out
        // a connection URL ("rediss://:password@host:port"), which ConfigurationOptions
        // does not understand, so translate that form here. The URL is parsed by hand
        // rather than with System.Uri because access keys are base64 and may contain
        // characters that Uri treats as authority delimiters.
        private static bool TryParseRedisUrl(string value, out ConfigurationOptions parsed)
        {
            parsed = null;

            bool useSsl;
            string remainder;
            if (value.StartsWith("rediss://", StringComparison.OrdinalIgnoreCase))
            {
                useSsl = true;
                remainder = value.Substring("rediss://".Length);
            }
            else if (value.StartsWith("redis://", StringComparison.OrdinalIgnoreCase))
            {
                useSsl = false;
                remainder = value.Substring("redis://".Length);
            }
            else
            {
                return false;
            }

            // Split credentials from the host on the last '@' so a password
            // containing '@' does not truncate the host.
            string credentials = null;
            int at = remainder.LastIndexOf('@');
            if (at >= 0)
            {
                credentials = remainder.Substring(0, at);
                remainder = remainder.Substring(at + 1);
            }

            // Drop any trailing database path or query string.
            int pathStart = remainder.IndexOfAny(new[] { '/', '?' });
            if (pathStart >= 0)
            {
                remainder = remainder.Substring(0, pathStart);
            }

            if (string.IsNullOrEmpty(remainder))
            {
                return false;
            }

            string host = remainder;
            int port = useSsl ? 6380 : 6379;
            int portSeparator = remainder.LastIndexOf(':');
            if (portSeparator >= 0)
            {
                host = remainder.Substring(0, portSeparator);
                if (!int.TryParse(remainder.Substring(portSeparator + 1), out port))
                {
                    return false;
                }
            }

            if (string.IsNullOrEmpty(host))
            {
                return false;
            }

            parsed = new ConfigurationOptions
            {
                Ssl = useSsl,
                AbortOnConnectFail = false,
            };
            parsed.EndPoints.Add(host, port);

            if (useSsl)
            {
                parsed.SslHost = host;
            }

            if (!string.IsNullOrEmpty(credentials))
            {
                int passwordSeparator = credentials.IndexOf(':');
                if (passwordSeparator >= 0)
                {
                    string user = credentials.Substring(0, passwordSeparator);
                    if (!string.IsNullOrEmpty(user))
                    {
                        parsed.User = Uri.UnescapeDataString(user);
                    }

                    parsed.Password = Uri.UnescapeDataString(credentials.Substring(passwordSeparator + 1));
                }
                else
                {
                    parsed.Password = Uri.UnescapeDataString(credentials);
                }
            }

            return true;
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapGrpcService<CartService>();
                endpoints.MapGrpcService<cartservice.services.HealthCheckService>();

                endpoints.MapGet("/", async context =>
                {
                    await context.Response.WriteAsync("Communication with gRPC endpoints must be made through a gRPC client. To learn how to create a client, visit: https://go.microsoft.com/fwlink/?linkid=2086909");
                });
            });
        }
    }
}
