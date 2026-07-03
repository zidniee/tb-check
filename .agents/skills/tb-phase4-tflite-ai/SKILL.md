---
name: tb-phase4-tflite-ai
description: Phase 4 - Scaffolds the On-Device AI inference logic using TensorFlow Lite.
---

# Skill Execution Steps
1. Invoke the `tb-tflite-expert` context.
2. Generate `lib/core/ai/tflite_service.dart`.
3. Set up the boilerplate to load an INT8 quantized model and run inference with the expected inputs (Audio + Questionnaire) and 4 Softmax outputs.
4. Stop execution and report that the foundational AI scaffolding is complete.
