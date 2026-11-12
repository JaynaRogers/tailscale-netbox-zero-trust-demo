# AI assistance disclosure

**Tool used:** ChatGPT (OpenAI).

**What I used AI for:** I used ChatGPT to help plan the demo, troubleshoot setup issues, draft deployment commands and configuration examples, and prepare documentation, diagrams, and presentation materials.

**What I reviewed or changed myself:** I provisioned the Oracle Cloud VM, deployed NetBox and Tailscale, configured access grants, and ran the connectivity tests. I checked AI-assisted instructions and documents against the actual environment, corrected inaccuracies, and made the final design decisions.

**Where AI helped:** It accelerated troubleshooting, suggested validation steps, and helped organize the implementation into a reproducible project and a customer-facing explanation.

**Where AI was wrong, incomplete, or misleading:** Early architecture diagrams were overly complicated and included an unnecessary emphasis on OpenSSH as a separately deployed component. I simplified the diagram and labeled the actual SSH-over-Tailscale access path. AI also initially implied that Mac connection timeouts proved policy enforcement; those results are consistent with restricted grants, but do not establish the exact cause without additional policy verification. I corrected the documentation to make that distinction explicit.

I used AI output as a starting point, not as authoritative evidence. I am responsible for the deployment, verification, design choices, and technical explanations.
