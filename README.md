# Leveraging cloud native infra for your intelligent apps

## Session Description

Deploying AI-enabled applications involves an application or microservice interacting with a LLM inferencing endpoint. Microservices architectures and a cloud native approach is ideal for hosting your intelligent apps. This session demonstrates how you can use Kubernetes and cloud-native tools to reduce operational overhead in building and running intelligent apps.

![image](https://github.com/user-attachments/assets/78a9c7ef-e16b-4b29-a61a-9514776339b7)


## Learning Outcomes

Key takeaways for this session are:

- AI is revolutionizing the industry
- Taking a cloud native approach makes adopting AI easier
- Use AI to help you operate your cloud native infrastructure and apps

## Technology Used

Azure services used in this session include:

- AKS Automatic
- Azure OpenAI
- Azure Service Bus
- Azure CosmosDB
- Azure Managed Grafana
- Azure Managed Prometheus
- Azure Log Analytics
- Copilot in Azure

Cloud Native tools used in this session include:

- Istio Service Mesh
- ArgoCD
- Argo Rollouts
- Gateway API

## Additional Resources and Continued Learning

If you would like to link the user to further learning, please enter that here.

| Resources          | Links                             | Description        |
|:-------------------|:----------------------------------|:-------------------|
| Azure Kubernetes Service (AKS)  | [Docs](https://aka.ms/aks/automatic) | Learn more about AKS Automatic |
| Azure OpenAI Service  | [Docs](https://learn.microsoft.com/azure/ai-services/openai/) | Learn more about Azure OpenAI Services |
| Azure Service Bus  | [Docs](https://learn.microsoft.com/azure/service-bus/) | Learn more about Azure Service Bus |
| Azure CosmosDB  | [Docs](https://learn.microsoft.com/azure/cosmos-db/) | Learn more about Azure CosmosDB |
| Azure Managed Grafana  | [Docs](https://learn.microsoft.com/azure/managed-grafana/) | Learn more about Azure Managed Grafana |
| Azure Managed Prometheus  | [Docs](https://learn.microsoft.com/azure/azure-monitor/essentials/prometheus-metrics-overview) | Learn more about Azure Managed Prometheus |
| Azure Monitor for Kubernetes | [Docs](https://learn.microsoft.com/azure/azure-monitor/containers/container-insights-overview) | Learn more about Azure Log Analytics |
| Istio Service Mesh | [Docs](https://learn.microsoft.com/en-us/azure/aks/istio-about) | Learn more about Istio-based Service Mesh add-on for AKS |
| ArgoCD | [Docs](https://argoproj.github.io/cd/) | Learn more about ArgoCD |
| Argo Rollouts | [Docs](https://argoproj.github.io/rollouts/) | Learn more about Argo Rollouts |
| Gateway API | [Docs](https://gateway-api.sigs.k8s.io/) | Learn more about Kubernetes Gateway API |

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->

<table>
<tr>
    <td align="center"><a href="http://learnanalytics.microsoft.com">
        <img src="https://github.com/pauldotyu.png" width="100px;" alt="Paul Yu
"/><br />
        <sub><b>Paul Yu
</b></sub></a><br />
            <a href="https://github.com/pauldotyu" title="talk">📢</a> 
    </td>
        <td align="center"><a href="http://learnanalytics.microsoft.com">
        <img src="https://github.com/vrapolinario.png" width="100px;" alt="Vinicius Apolinario
"/><br />
        <sub><b>Vinicius Apolinario
</b></sub></a><br />
            <a href="https://github.com/vrapolinario" title="talk">📢</a> 
    </td>
</tr>

</table>

<!-- ALL-CONTRIBUTORS-LIST:END -->


## Responsible AI
Microsoft is committed to helping our customers use our AI products responsibly, sharing our learnings, and building trust-based partnerships through tools like Transparency Notes and Impact Assessments. Many of these resources can be found at https://aka.ms/RAI. Microsoft’s approach to responsible AI is grounded in our AI principles of fairness, reliability and safety, privacy and security, inclusiveness, transparency, and accountability.

Large-scale natural language, image, and speech models - like the ones used in this sample - can potentially behave in ways that are unfair, unreliable, or offensive, in turn causing harms. Please consult the Azure OpenAI service Transparency note to be informed about risks and limitations. The recommended approach to mitigating these risks is to include a safety system in your architecture that can detect and prevent harmful behavior. Azure AI Content Safety provides an independent layer of protection, able to detect harmful user-generated and AI-generated content in applications and services. Azure AI Content Safety includes text and image APIs that allow you to detect material that is harmful. We also have an interactive Content Safety Studio that allows you to view, explore and try out sample code for detecting harmful content across different modalities. The following quickstart documentation guides you through making requests to the service.

Another aspect to take into account is the overall application performance. With multi-modal and multi-models applications, we consider performance to mean that the system performs as you and your users expect, including not generating harmful outputs. It's important to assess the performance of your overall application using generation quality and risk and safety metrics.

You can evaluate your AI application in your development environment using the prompt flow SDK. Given either a test dataset or a target, your generative AI application generations are quantitatively measured with built-in evaluators or custom evaluators of your choice. To get started with the prompt flow sdk to evaluate your system, you can follow the quickstart guide. Once you execute an evaluation run, you can visualize the results in Azure AI Studio. Empowering responsible AI practices | Microsoft AI Explore how Microsoft is committed to advancing AI in a way that is driven by ethical principles that put people first.
## Content Owners
