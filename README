<a href="https://livekit.io/">
  <img src="./.github/assets/livekit-mark.png" alt="LiveKit logo" width="100" height="100">
</a>

# Swift Voice Assistant

<p>
  <a href="https://cloud.livekit.io/projects/p_/sandbox"><strong>Deploy a sandbox app</strong></a>
  •
  <a href="https://docs.livekit.io/agents/overview/">LiveKit Agents Docs</a>
  •
  <a href="https://livekit.io/cloud">LiveKit Cloud</a>
  •
  <a href="https://blog.livekit.io/">Blog</a>
</p>

A simple example AI voice assistant using the LiveKit [Swift SDK](https://github.com/livekit/client-sdk-swift).

This example is made for iOS, iPadOS, macOS, and visionOS.

## Installation

### Using the LiveKit CLI

The easiest way to get started is to use the [LiveKit CLI](https://docs.livekit.io/home/cli/cli-setup/). Run the following command to bootstrap this template:

```bash
lk app create --template voice-assistant-swift [--sandbox <sandboxID>]
```

Then follow instructions to [set up an agent](#agent) for your app to talk to.

### Manual Installation

Clone the repository and then either create a `VoiceAssistant/.env.xcconfig` with a `LIVEKIT_SANDBOX_ID` (if using a hosted Token Server via [Sandboxes](https://cloud.livekit.io/projects/p_/sandbox)), or open `TokenService.swift` and add your [manually generated](#token-generation) URL and token.

Then follow instructions to [set up an agent](#agent) for your app to talk to.

## Token Generation

In production, you will want to host your own token server to generate tokens in order for users of your app to join LiveKit rooms. But while prototyping, you can either hardcode your token, or use a hosted Token Server via [Sandboxes](https://cloud.livekit.io/projects/p_/sandbox)). 

## Agent

This example app requires an AI agent to communicate with. You can use one of our example agents in [livekit-examples](https://github.com/livekit-examples/), or create your own following one of our [agent quickstarts](https://docs.livekit.io/agents/quickstart/).
