import 'package:flutter/material.dart';

class SteperItemSection extends StatefulWidget {
  final Widget contentWidget;
  final int currentStep;
  final Function(int) onStepTapped;
  final Function onContinue;
  final Function onCancel;

  const SteperItemSection({
    Key? key,
    required this.contentWidget,
    required this.currentStep,
    required this.onStepTapped,
    required this.onContinue,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<SteperItemSection> createState() => _SteperItemSectionState();
}

class _SteperItemSectionState extends State<SteperItemSection> {
  List<Map<String, String>> steplist = [
    {'task': '1', 'content': "Step 1"},
    {'task': '2', 'content': "Step 2"},
    {'task': '3', 'content': "Step 3"},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double stepperHeight = constraints.maxHeight;
        double stepperWidth = constraints.maxWidth;

        return SingleChildScrollView(
          child: SizedBox(
            height: stepperHeight * 0.9, // Adjust as needed
            width: stepperWidth,
            child: Stepper(
              physics: const NeverScrollableScrollPhysics(),
              connectorThickness: 1,
              elevation: 0,
              type: StepperType.horizontal,
              currentStep: widget.currentStep,
              onStepTapped: (int step) {
                widget.onStepTapped(step);
              },
              controlsBuilder: (BuildContext context, ControlsDetails controls) {
                return Row(
                  children: [

                  ],
                );
              },
              steps: getSteps(),
            ),
          ),
        );
      },
    );
  }

  List<Step> getSteps() {
    return steplist.asMap().entries.map<Step>((e) {
      var i = e.key;
      var item = e.value;
      return Step(
        state: widget.currentStep > i ? StepState.complete : StepState.indexed,
        isActive: widget.currentStep >= i,
        title: const SizedBox.shrink(),
        label: Text(
          StepState.indexed == StepState.indexed ? item['content'] ?? "" : "",
          style: TextStyle(
              fontSize: 14,
              color: widget.currentStep >= i ? Colors.blue : null),
        ),
        content: widget.contentWidget,
      );
    }).toList();
  }
}
