# GodotGithubActionsExample
Minimal Godot Project to test out automated process of uploading a game to itch.io

# High Level Overview
```
.
├── .github/workflows/
│   └── docker-image.yml        <-- THE TRIGGER: Manual 1-click GitHub Action to deploy.
│
├── continuous-integration/   <-- THE ENGINE: Dockerfile & Shell scripts. 
│                             |   Uses Butler to containerize and upload the build.
│
├── game/                     <-- THE SOURCE: A minimal Godot 4 project 
│                             |   used to test the automation pipeline.
│
└── README.md
```
