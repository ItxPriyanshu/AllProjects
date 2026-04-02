class doctypesymptom {
  late Map<String, List<String>> symptoms;

  doctypesymptom() {
    symptoms = {
      "Cardiologist": [
        "Chest pain",
        "Upper body pain",
        "Shortness of breath",
        "Irregular heartbeat",
        "Weakness",
        "Dizziness",
        "Sweating without exercise",
        "Nausea",
        "Fainting",
      ],
      "Dermatologist": [
        "Rash",
        "Itching",
        "Redness",
        "Dry skin",
        "Blisters",
        "Swelling",
        "Painful skin",
        "Skin discoloration",
        "Hair loss",
      ],
      "General Physician": [
        "Fever",
        "Cough",
        "Sore throat",
        "Headache",
        "Fatigue",
        "Body aches",
        "Nausea",
        "Vomiting",
        "Diarrhea",
        "Runny or blocked nose",
        "Loss of appetite"
      ],
      "Neurologist": [
        "Headache",
        "Dizziness",
        "Numbness or tingling",
        "Weakness",
        "Memory problems",
        "Difficulty concentrating",
        "Seizures",
        "Vision problems",
        "Speech difficulties",
        "Numbness",

      ],
        "Orthopedist": [
          "Joint pain",
          "Back pain",
          "Muscle pain",
          "Swelling",
          "Stiffness",
          "Limited range of motion",
          "Numbness or tingling",
          "Weakness",
          "Deformity"
        ],
    };
  }
}