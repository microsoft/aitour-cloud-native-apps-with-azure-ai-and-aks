
## How To Use

Welcome!

We're glad you are here and look forward to your delivery of this amazing content. As an experienced presenter, we know you know HOW to present so this guide will focus on WHAT you need to present. It will provide you a full run-through of the presentation created by the presentation design team. 

Along with the video of the presentation, this document will link to all the assets you need to successfully present including PowerPoint slides and demo instructions &
code.

1. Clone this repo
1. Read presentation in its entirety.
1. Watch the video demos that are embedded in the presentation
1. Read the [demo instructions](./demo/WALKTHROUGH.md) and do the demo at least once manually before presenting and delete the resources after to avoid charges and quota limits.
1. Open a terminal
1. Log into your Azure tenant/subscription using Azure CLI
1. Run the `make setup` command which will invoke the [`setup.sh`](./demo/setup.sh) script to setup a demo environment on the day of the presentation
1. Run the `make demo` command which will invoke the [`demo.sh`](./demo/demo.sh) script to run the demo on the day of the presentation
1. Ask questions of the Lead Presenter
1. When complete, run the `make cleanup` command which will invoke the [`clean.sh`](./demo/cleanup.sh) script to clean up the demo environment and delete all resources created during the demo
1. To restart the demo, run the `make reset` command which will invoke the [`reset.sh`](./demo/reset.sh) script to delete the application and reset the forked repo to its original state

## File Summary

| Resources              | Links                                     | Description                                                        |
|------------------------|-------------------------------------------|--------------------------------------------------------------------|
| PowerPoint English     | [Presentation](https://aka.ms/AAryjht)    | Slides                                                             |
| PowerPoint Spanish     | [ES Presentation](https://aka.ms/AAs7u29) | ES Slides                                                          |
| PowerPoint Portuguese  | [PT Presentation](https://aka.ms/AAs7ets) | PT Slides                                                          |
| Demo Instructions      | [Walkthrough](./demo/WALKTHROUGH.md)      | Step-by-step instructions for manually setting up and running demo |
| Demo Setup Script      | [Script](./demo/setup.sh)                 | Script to setup demo environment                                   |
| Demo Script            | [Script](./demo/demo.md)                  | Script to run the demo                                             |
