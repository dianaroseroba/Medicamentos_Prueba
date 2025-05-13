import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- agregado
import 'package:get/get.dart';

import 'package:application_medicines/auth_controller.dart';
import 'package:application_medicines/medication.dart';
import 'package:application_medicines/medication_controller.dart';
import 'package:application_medicines/notification_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final MedicationController medicationController = Get.find<MedicationController>();
  final NotificationService notificationService = Get.find<NotificationService>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  String? nameError;
  String? dosageError;

  void _validateAndSave() async {
    setState(() {
      nameError = nameController.text.trim().isEmpty ? 'El nombre es obligatorio' : null;
      dosageError = dosageController.text.trim().isEmpty ? 'La dosis es obligatoria' : null;
    });

    if (nameError == null && dosageError == null) {
      final now = DateTime.now();
      final medicationTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.value.hour,
        selectedTime.value.minute,
      );

      final medication = Medication(
        id: '',
        name: nameController.text.trim(),
        dosage: dosageController.text.trim(),
        time: medicationTime,
        userId: (await Get.find<AuthController>().account.get()).$id,
      );

      await medicationController.addMedication(medication);
      await notificationService.scheduleMedicationNotification(
        'Es hora de tu medicamento',
        'Toma ${medication.name} - ${medication.dosage}',
        medicationTime,
      );

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Medicamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del Medicamento',
                border: const OutlineInputBorder(),
                errorText: nameError,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dosageController,
              keyboardType: TextInputType.number, // <-- teclado numérico
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // <-- solo números
              decoration: InputDecoration(
                labelText: 'Dosis',
                border: const OutlineInputBorder(),
                errorText: dosageError,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ListTile(
                title: const Text('Hora de la Medicación'),
                subtitle: Text(
                  '${selectedTime.value.hour}:${selectedTime.value.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime.value,
                  );
                  if (time != null) {
                    selectedTime.value = time;
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _validateAndSave,
              child: const Text('Guardar Medicamento'),
            ),
          ],
        ),
      ),
    );
  }
}
