# gks-template

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: library](https://img.shields.io/badge/Type-library-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

GKS template chart

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configuration. [Documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) |
| autoscaling | object | `{}` | Autoscaling configuration. [Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). |
| autoscaling.enabled | bool | `false` | Whether to enable HPA or not |
| autoscaling.maxReplicas | int | `100` | Max amount of replicas |
| autoscaling.minReplicas | int | `1` | Min amount of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| deploymentAnnotations | list | `[]` | Deployment level annotations. |
| env | list | `[]` | Environment variables. [Documentation](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/). |
| envFrom | list | `[]` | Environment variables mapping. [Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/). |
| fullnameOverride | string | `""` | FullName override. |
| image | object | `{}` | Image configuration. [Documentation](https://kubernetes.io/docs/concepts/containers/images/). |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"harbor.teamgeta.net/cervera/giftshop-web/test"` | Image repository. |
| image.tag | string | `""` | Image tag. |
| imagePullSecrets | list | `[]` | List of the secret names to use for image pulling. |
| nameOverride | string | `""` | Name override. |
| nodeSelector | object | `{}` | Node selector configuration. [Documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). |
| podAnnotations | object | `{}` | Pod level annotations. |
| podSecurityContext | object | `{}` | Pod security context. [Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). |
| probes | object | `{}` | Probes configuration. [Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/). |
| probes.liveness | object | `{}` | Liveness probe configuration. |
| probes.readiness | object | `{}` | readiness probe configuration. |
| probes.startup | object | `{}` | Startup probe configuration. |
| replicaCount | int | `1` | Number of replicas to run. |
| resources | object | `{}` | Resources configuration. [Documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/). |
| securityContext | object | `{}` | Container security context. [Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). |
| service | object | `{}` | Service configuration. [Documentation](https://kubernetes.io/docs/concepts/services-networking/service/). |
| service.port | int | `80` | Service port |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount | object | `{}` | Service account configuration. [Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/). |
| serviceAccount.annotations | object | `{}` | Service account annotations. Example: `{ foo/bar: "Some annotation" }`. |
| serviceAccount.create | bool | `false` | Whether to create service account or not. |
| serviceAccount.name | string | `""` | Service account name |
| serviceAnnotations | list | `[]` | Service level annotations. |
| tenant | string | `""` | Tenant name. |
| tolerations | list | `[]` | Tolerations configuration. [Documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/). |
| volumeMounts | list | `[]` | Volume mounts configuration. [Documentation](https://kubernetes.io/docs/concepts/storage/volumes/). |
| volumes | list | `[]` | Volumes configuration. [Documentation](https://kubernetes.io/docs/concepts/storage/volumes/). |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)