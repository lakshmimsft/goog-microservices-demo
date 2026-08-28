extension radius

param environment string

@secure()
param registryPassword string

@secure()
param registryUsername string

resource googApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'goog-microservices-demo'
  properties: {
    environment: environment
  }
}

resource redisCache 'Radius.Data/redisCaches@2025-08-01-preview' = {
  name: 'redis'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/cartservice/src/Startup.cs#L37'
    size: 'S'
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: '.radius/app.bicep#L28'
    data: {
      password: {
        value: registryPassword
      }
      username: {
        value: registryUsername
      }
    }
  }
}

resource adserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'adservice-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/adservice/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/adservice?ref=9ad733536b756684603c6100ebc6953d91f9c911'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource cartserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'cartservice-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/cartservice/src/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/cartservice/src?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource checkoutserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'checkoutservice-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/checkoutservice/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/checkoutservice?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource currencyserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'currencyservice-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/currencyservice/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/currencyservice?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource emailserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'emailservice-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/emailservice/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/emailservice?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource frontendImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'frontend-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/frontend/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/frontend?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource loadgeneratorImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'loadgenerator-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/loadgenerator/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/loadgenerator?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource paymentserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'paymentservice-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/paymentservice/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/paymentservice?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource productcatalogserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'productcatalogservice-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/productcatalogservice/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/productcatalogservice?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource recommendationserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'recommendationservice-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/recommendationservice/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/recommendationservice?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource shippingserviceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'shippingservice-image'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/shippingservice/Dockerfile'
    build: {
      source: 'git::https://github.com/lakshmimsft/goog-microservices-demo.git//src/shippingservice?ref=a173b01624f562f52f649d2f3152a68db533d689'
      platforms: [
        'linux/arm64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource adserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'adservice'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/adservice/src/main/java/hipstershop/AdService.java#L223'
    containers: {
      ad: {
        image: adserviceImage.properties.imageReference
        env: {
          PORT: {
            value: '9555'
          }
        }
        ports: {
          grpc: {
            containerPort: 9555
          }
        }
      }
    }
  }
}

resource cartserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'cartservice'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/cartservice/src/Program.cs#L19'
    containers: {
      cart: {
        image: cartserviceImage.properties.imageReference
        env: {
          REDIS_ADDR: {
            valueFrom: {
              secretKeyRef: {
                secretName: redisCache.properties.secrets.name
                key: 'url'
              }
            }
          }
        }
        ports: {
          grpc: {
            containerPort: 7070
          }
        }
      }
    }
  }
}

resource checkoutserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'checkoutservice'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/checkoutservice/main.go#L88'
    containers: {
      checkout: {
        image: checkoutserviceImage.properties.imageReference
        env: {
          CART_SERVICE_ADDR: {
            value: '${cartserviceContainer.properties.hosts.cart}:7070'
          }
          CURRENCY_SERVICE_ADDR: {
            value: '${currencyserviceContainer.properties.hosts.currency}:7000'
          }
          EMAIL_SERVICE_ADDR: {
            value: '${emailserviceContainer.properties.hosts.email}:8080'
          }
          PAYMENT_SERVICE_ADDR: {
            value: '${paymentserviceContainer.properties.hosts.payment}:50051'
          }
          PORT: {
            value: '5050'
          }
          PRODUCT_CATALOG_SERVICE_ADDR: {
            value: '${productcatalogserviceContainer.properties.hosts.productcatalog}:3550'
          }
          SHIPPING_SERVICE_ADDR: {
            value: '${shippingserviceContainer.properties.hosts.shipping}:50051'
          }
        }
        ports: {
          grpc: {
            containerPort: 5050
          }
        }
      }
    }
  }
}

resource currencyserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'currencyservice'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/currencyservice/server.js#L182'
    containers: {
      currency: {
        image: currencyserviceImage.properties.imageReference
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '7000'
          }
        }
        ports: {
          grpc: {
            containerPort: 7000
          }
        }
      }
    }
  }
}

resource emailserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'emailservice'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/emailservice/email_server.py#L119'
    containers: {
      email: {
        image: emailserviceImage.properties.imageReference
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '8080'
          }
        }
        ports: {
          grpc: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource frontendContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'frontend'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/frontend/main.go#L91'
    containers: {
      frontend: {
        image: frontendImage.properties.imageReference
        env: {
          AD_SERVICE_ADDR: {
            value: '${adserviceContainer.properties.hosts.ad}:9555'
          }
          CART_SERVICE_ADDR: {
            value: '${cartserviceContainer.properties.hosts.cart}:7070'
          }
          CHECKOUT_SERVICE_ADDR: {
            value: '${checkoutserviceContainer.properties.hosts.checkout}:5050'
          }
          CURRENCY_SERVICE_ADDR: {
            value: '${currencyserviceContainer.properties.hosts.currency}:7000'
          }
          ENABLE_PROFILER: {
            value: '0'
          }
          PORT: {
            value: '8080'
          }
          PRODUCT_CATALOG_SERVICE_ADDR: {
            value: '${productcatalogserviceContainer.properties.hosts.productcatalog}:3550'
          }
          RECOMMENDATION_SERVICE_ADDR: {
            value: '${recommendationserviceContainer.properties.hosts.recommendation}:8080'
          }
          SHIPPING_SERVICE_ADDR: {
            value: '${shippingserviceContainer.properties.hosts.shipping}:50051'
          }
          SHOPPING_ASSISTANT_SERVICE_ADDR: {
            value: 'shoppingassistantservice:80'
          }
        }
        ports: {
          web: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource loadgeneratorContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'loadgenerator'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/loadgenerator/locustfile.py#L90'
    containers: {
      loadgenerator: {
        image: loadgeneratorImage.properties.imageReference
        env: {
          FRONTEND_ADDR: {
            value: '${frontendContainer.properties.hosts.frontend}:8080'
          }
          RATE: {
            value: '1'
          }
          USERS: {
            value: '10'
          }
        }
      }
    }
  }
}

resource paymentserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'paymentservice'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/paymentservice/index.js#L75'
    containers: {
      payment: {
        image: paymentserviceImage.properties.imageReference
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '50051'
          }
        }
        ports: {
          grpc: {
            containerPort: 50051
          }
        }
      }
    }
  }
}

resource productcatalogserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'productcatalogservice'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/productcatalogservice/server.go#L68'
    containers: {
      productcatalog: {
        image: productcatalogserviceImage.properties.imageReference
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '3550'
          }
        }
        ports: {
          grpc: {
            containerPort: 3550
          }
        }
      }
    }
  }
}

resource recommendationserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'recommendationservice'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/recommendationservice/recommendation_server.py#L139'
    containers: {
      recommendation: {
        image: recommendationserviceImage.properties.imageReference
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '8080'
          }
          PRODUCT_CATALOG_SERVICE_ADDR: {
            value: '${productcatalogserviceContainer.properties.hosts.productcatalog}:3550'
          }
        }
        ports: {
          grpc: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource shippingserviceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'shippingservice'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'src/shippingservice/main.go#L56'
    containers: {
      shipping: {
        image: shippingserviceImage.properties.imageReference
        env: {
          DISABLE_PROFILER: {
            value: '1'
          }
          PORT: {
            value: '50051'
          }
        }
        ports: {
          grpc: {
            containerPort: 50051
          }
        }
      }
    }
  }
}

resource frontendRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'frontend-route'
  properties: {
    environment: environment
    application: googApp.id
    codeReference: 'istio-manifests/frontend-gateway.yaml#L16'
    kind: 'HTTP'
    rules: [
      {
        matches: [
          {
            httpPath: '/'
          }
        ]
        destinationContainer: {
          resourceId: frontendContainer.id
          containerName: 'frontend'
          containerPort: 8080
        }
      }
    ]
  }
}
