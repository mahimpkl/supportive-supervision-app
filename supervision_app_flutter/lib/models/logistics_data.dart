class LogisticsData {
  // B1 Medicine availability with quantities - Antihypertensives
  final String? amlodipine510mg;
  final int? amlodipine510mgQuantity;
  final String? amlodipine510mgUnits;
  final String? enalapril2510mg;
  final int? enalapril2510mgQuantity;
  final String? enalapril2510mgUnits;
  final String? losartan2550mg;
  final int? losartan2550mgQuantity;
  final String? losartan2550mgUnits;
  final String? hydrochlorothiazide_12_5_25mg;
  final int? hydrochlorothiazide_12_5_25mgQuantity;
  final String? hydrochlorothiazide_12_5_25mgUnits;
  final String? chlorthalidone_6_25_12_5mg;
  final int? chlorthalidone_6_25_12_5mgQuantity;
  final String? chlorthalidone_6_25_12_5mgUnits;
  final String? otherAntihypertensives;
  final int? otherAntihypertensivesQuantity;
  final String? otherAntihypertensivesUnits;
  final String? otherAntihypertensivesSpecify;
  
  // Statins
  final String? atorvastatin5mg;
  final int? atorvastatin5mgQuantity;
  final String? atorvastatin5mgUnits;
  final String? atorvastatin10mg;
  final int? atorvastatin10mgQuantity;
  final String? atorvastatin10mgUnits;
  final String? atorvastatin20mg;
  final int? atorvastatin20mgQuantity;
  final String? atorvastatin20mgUnits;
  final String? otherStatins;
  final int? otherStatinsQuantity;
  final String? otherStatinsUnits;
  final String? otherStatinsSpecify;
  
  // Diabetes medications
  final String? metformin500mg;
  final int? metformin500mgQuantity;
  final String? metformin500mgUnits;
  final String? metformin1000mg;
  final int? metformin1000mgQuantity;
  final String? metformin1000mgUnits;
  final String? glimepiride_1_2mg;
  final int? glimepiride_1_2mgQuantity;
  final String? glimepiride_1_2mgUnits;
  final String? gliclazide_40_80mg;
  final int? gliclazide_40_80mgQuantity;
  final String? gliclazide_40_80mgUnits;
  final String? glipizide_2_5_5mg;
  final int? glipizide_2_5_5mgQuantity;
  final String? glipizide_2_5_5mgUnits;
  final String? sitagliptin50mg;
  final int? sitagliptin50mgQuantity;
  final String? sitagliptin50mgUnits;
  final String? pioglitazone5mg;
  final int? pioglitazone5mgQuantity;
  final String? pioglitazone5mgUnits;
  final String? empagliflozin10mg;
  final int? empagliflozin10mgQuantity;
  final String? empagliflozin10mgUnits;
  final String? insulinSolubleInj;
  final int? insulinSolubleInjQuantity;
  final String? insulinSolubleInjUnits;
  final String? insulinNphInj;
  final int? insulinNphInjQuantity;
  final String? insulinNphInjUnits;
  final String? otherHypoglycemicAgents;
  final int? otherHypoglycemicAgentsQuantity;
  final String? otherHypoglycemicAgentsUnits;
  final String? otherHypoglycemicAgentsSpecify;
  
  // Emergency and cardiovascular
  final String? dextrose25Solution;
  final int? dextrose25SolutionQuantity;
  final String? dextrose25SolutionUnits;
  final String? aspirin75mg;
  final int? aspirin75mgQuantity;
  final String? aspirin75mgUnits;
  final String? clopidogrel75mg;
  final int? clopidogrel75mgQuantity;
  final String? clopidogrel75mgUnits;
  final String? metoprolol_succinate_12_5_25_50mg;
  final int? metoprolol_succinate_12_5_25_50mgQuantity;
  final String? metoprolol_succinate_12_5_25_50mgUnits;
  final String? isosorbideDinitrate5mg;
  final int? isosorbideDinitrate5mgQuantity;
  final String? isosorbideDinitrate5mgUnits;
  final String? otherDrugs;
  final int? otherDrugsQuantity;
  final String? otherDrugsUnits;
  final String? otherDrugsSpecify;
  
  // Antibiotics
  final String? amoxicillinClavulanicPotassium625mg;
  final int? amoxicillinClavulanicPotassium625mgQuantity;
  final String? amoxicillinClavulanicPotassium625mgUnits;
  final String? azithromycin500mg;
  final int? azithromycin500mgQuantity;
  final String? azithromycin500mgUnits;
  final String? otherAntibiotics;
  final int? otherAntibioticsQuantity;
  final String? otherAntibioticsUnits;
  final String? otherAntibioticsSpecify;
  
  // Respiratory
  final String? salbutamolDpi;
  final int? salbutamolDpiQuantity;
  final String? salbutamolDpiUnits;
  final String? salbutamol;
  final int? salbutamolQuantity;
  final String? salbutamolUnits;
  final String? ipratropium;
  final int? ipratropiumQuantity;
  final String? ipratropiumUnits;
  final String? tiotropiumBromide;
  final int? tiotropiumBromideQuantity;
  final String? tiotropiumBromideUnits;
  final String? formoterol;
  final int? formoterolQuantity;
  final String? formoterolUnits;
  final String? otherBronchodilators;
  final int? otherBronchodilatorsQuantity;
  final String? otherBronchodilatorsUnits;
  final String? otherBronchodilatorsSpecify;
  final String? prednisolone_5_10_20mg;
  final int? prednisolone_5_10_20mgQuantity;
  final String? prednisolone_5_10_20mgUnits;
  final String? otherSteroidsOral;
  final int? otherSteroidsOralQuantity;
  final String? otherSteroidsOralUnits;
  final String? otherSteroidsOralSpecify;

  // B1 responses and validation
  final String? b1Response;
  final String? b1Comment;
  final String? b1RespondentsComment;
  final String? b1ValidationNote;

  // B2-B5 responses
  final String? b2Response;
  final String? b2Comment;
  final String? b2RespondentsComment;
  final String? b2ValidationNote;
  final bool? b2RandomRecordsChecked;
  final String? b2ExplanationIfNotInUse;
  
  final String? b3Response;
  final String? b3Comment;
  final String? b3RespondentsComment;
  final String? b3ValidationNote;
  final bool? b3ExpiryDateVerified;
  final bool? b3StorageConditionsVerified;
  
  final String? b4Response;
  final String? b4Comment;
  final String? b4RespondentsComment;
  final String? b4ValidationNote;
  final bool? b4ExpiryDateVerified;
  final bool? b4StorageConditionsVerified;
  
  final String? b5Response;
  final String? b5Comment;
  final String? b5RespondentsComment;
  final String? b5ValidationNote;

  // Category-specific comments
  final String? antihypertensiveComments;
  final String? statinComments;
  final String? diabetesMedicationComments;
  final String? cardiovascularMedicationComments;
  final String? respiratoryMedicationComments;

  // Medicine quantities tracking
  final Map<String, dynamic>? medicineQuantities;

  // Additional tracking
  final bool? expiryDatesChecked;
  final bool? storageConditionsVerified;
  final String? actionsAgreed;

  LogisticsData({
    this.amlodipine510mg,
    this.amlodipine510mgQuantity,
    this.amlodipine510mgUnits,
    this.enalapril2510mg,
    this.enalapril2510mgQuantity,
    this.enalapril2510mgUnits,
    this.losartan2550mg,
    this.losartan2550mgQuantity,
    this.losartan2550mgUnits,
    this.hydrochlorothiazide_12_5_25mg,
    this.hydrochlorothiazide_12_5_25mgQuantity,
    this.hydrochlorothiazide_12_5_25mgUnits,
    this.chlorthalidone_6_25_12_5mg,
    this.chlorthalidone_6_25_12_5mgQuantity,
    this.chlorthalidone_6_25_12_5mgUnits,
    this.otherAntihypertensives,
    this.otherAntihypertensivesQuantity,
    this.otherAntihypertensivesUnits,
    this.otherAntihypertensivesSpecify,
    this.atorvastatin5mg,
    this.atorvastatin5mgQuantity,
    this.atorvastatin5mgUnits,
    this.atorvastatin10mg,
    this.atorvastatin10mgQuantity,
    this.atorvastatin10mgUnits,
    this.atorvastatin20mg,
    this.atorvastatin20mgQuantity,
    this.atorvastatin20mgUnits,
    this.otherStatins,
    this.otherStatinsQuantity,
    this.otherStatinsUnits,
    this.otherStatinsSpecify,
    this.metformin500mg,
    this.metformin500mgQuantity,
    this.metformin500mgUnits,
    this.metformin1000mg,
    this.metformin1000mgQuantity,
    this.metformin1000mgUnits,
    this.glimepiride_1_2mg,
    this.glimepiride_1_2mgQuantity,
    this.glimepiride_1_2mgUnits,
    this.gliclazide_40_80mg,
    this.gliclazide_40_80mgQuantity,
    this.gliclazide_40_80mgUnits,
    this.glipizide_2_5_5mg,
    this.glipizide_2_5_5mgQuantity,
    this.glipizide_2_5_5mgUnits,
    this.sitagliptin50mg,
    this.sitagliptin50mgQuantity,
    this.sitagliptin50mgUnits,
    this.pioglitazone5mg,
    this.pioglitazone5mgQuantity,
    this.pioglitazone5mgUnits,
    this.empagliflozin10mg,
    this.empagliflozin10mgQuantity,
    this.empagliflozin10mgUnits,
    this.insulinSolubleInj,
    this.insulinSolubleInjQuantity,
    this.insulinSolubleInjUnits,
    this.insulinNphInj,
    this.insulinNphInjQuantity,
    this.insulinNphInjUnits,
    this.otherHypoglycemicAgents,
    this.otherHypoglycemicAgentsQuantity,
    this.otherHypoglycemicAgentsUnits,
    this.otherHypoglycemicAgentsSpecify,
    this.dextrose25Solution,
    this.dextrose25SolutionQuantity,
    this.dextrose25SolutionUnits,
    this.aspirin75mg,
    this.aspirin75mgQuantity,
    this.aspirin75mgUnits,
    this.clopidogrel75mg,
    this.clopidogrel75mgQuantity,
    this.clopidogrel75mgUnits,
    this.metoprolol_succinate_12_5_25_50mg,
    this.metoprolol_succinate_12_5_25_50mgQuantity,
    this.metoprolol_succinate_12_5_25_50mgUnits,
    this.isosorbideDinitrate5mg,
    this.isosorbideDinitrate5mgQuantity,
    this.isosorbideDinitrate5mgUnits,
    this.otherDrugs,
    this.otherDrugsQuantity,
    this.otherDrugsUnits,
    this.otherDrugsSpecify,
    this.amoxicillinClavulanicPotassium625mg,
    this.amoxicillinClavulanicPotassium625mgQuantity,
    this.amoxicillinClavulanicPotassium625mgUnits,
    this.azithromycin500mg,
    this.azithromycin500mgQuantity,
    this.azithromycin500mgUnits,
    this.otherAntibiotics,
    this.otherAntibioticsQuantity,
    this.otherAntibioticsUnits,
    this.otherAntibioticsSpecify,
    this.salbutamolDpi,
    this.salbutamolDpiQuantity,
    this.salbutamolDpiUnits,
    this.salbutamol,
    this.salbutamolQuantity,
    this.salbutamolUnits,
    this.ipratropium,
    this.ipratropiumQuantity,
    this.ipratropiumUnits,
    this.tiotropiumBromide,
    this.tiotropiumBromideQuantity,
    this.tiotropiumBromideUnits,
    this.formoterol,
    this.formoterolQuantity,
    this.formoterolUnits,
    this.otherBronchodilators,
    this.otherBronchodilatorsQuantity,
    this.otherBronchodilatorsUnits,
    this.otherBronchodilatorsSpecify,
    this.prednisolone_5_10_20mg,
    this.prednisolone_5_10_20mgQuantity,
    this.prednisolone_5_10_20mgUnits,
    this.otherSteroidsOral,
    this.otherSteroidsOralQuantity,
    this.otherSteroidsOralUnits,
    this.otherSteroidsOralSpecify,
    this.b1Response,
    this.b1Comment,
    this.b1RespondentsComment,
    this.b1ValidationNote,
    this.b2Response,
    this.b2Comment,
    this.b2RespondentsComment,
    this.b2ValidationNote,
    this.b2RandomRecordsChecked,
    this.b2ExplanationIfNotInUse,
    this.b3Response,
    this.b3Comment,
    this.b3RespondentsComment,
    this.b3ValidationNote,
    this.b3ExpiryDateVerified,
    this.b3StorageConditionsVerified,
    this.b4Response,
    this.b4Comment,
    this.b4RespondentsComment,
    this.b4ValidationNote,
    this.b4ExpiryDateVerified,
    this.b4StorageConditionsVerified,
    this.b5Response,
    this.b5Comment,
    this.b5RespondentsComment,
    this.b5ValidationNote,
    this.antihypertensiveComments,
    this.statinComments,
    this.diabetesMedicationComments,
    this.cardiovascularMedicationComments,
    this.respiratoryMedicationComments,
    this.medicineQuantities,
    this.expiryDatesChecked,
    this.storageConditionsVerified,
    this.actionsAgreed,
  });

  factory LogisticsData.fromJson(Map<String, dynamic> json) {
    return LogisticsData(
      // B1 responses
      b1Response: json['b1_response'] ?? json['b1Response'],
      b1Comment: json['b1_comment'] ?? json['b1Comment'],
      b1RespondentsComment: json['b1_respondents_comment'] ?? json['b1RespondentsComment'],
      b1ValidationNote: json['b1_validation_note'] ?? json['b1ValidationNote'],
      
      // Antihypertensives
      amlodipine510mg: json['amlodipine_5_10mg'] ?? json['amlodipine510mg'],
      amlodipine510mgQuantity: json['amlodipine_5_10mg_quantity'] ?? json['amlodipine510mgQuantity'],
      amlodipine510mgUnits: json['amlodipine_5_10mg_units'] ?? json['amlodipine510mgUnits'],
      enalapril2510mg: json['enalapril_2_5_10mg'] ?? json['enalapril2510mg'],
      enalapril2510mgQuantity: json['enalapril_2_5_10mg_quantity'] ?? json['enalapril2510mgQuantity'],
      enalapril2510mgUnits: json['enalapril_2_5_10mg_units'] ?? json['enalapril2510mgUnits'],
      losartan2550mg: json['losartan_25_50mg'] ?? json['losartan2550mg'],
      losartan2550mgQuantity: json['losartan_25_50mg_quantity'] ?? json['losartan2550mgQuantity'],
      losartan2550mgUnits: json['losartan_25_50mg_units'] ?? json['losartan2550mgUnits'],
      hydrochlorothiazide_12_5_25mg: json['hydrochlorothiazide_12_5_25mg'],
      hydrochlorothiazide_12_5_25mgQuantity: json['hydrochlorothiazide_12_5_25mg_quantity'],
      hydrochlorothiazide_12_5_25mgUnits: json['hydrochlorothiazide_12_5_25mg_units'],
      chlorthalidone_6_25_12_5mg: json['chlorthalidone_6_25_12_5mg'],
      chlorthalidone_6_25_12_5mgQuantity: json['chlorthalidone_6_25_12_5mg_quantity'],
      chlorthalidone_6_25_12_5mgUnits: json['chlorthalidone_6_25_12_5mg_units'],
      otherAntihypertensives: json['other_antihypertensives'] ?? json['otherAntihypertensives'],
      otherAntihypertensivesQuantity: json['other_antihypertensives_quantity'] ?? json['otherAntihypertensivesQuantity'],
      otherAntihypertensivesUnits: json['other_antihypertensives_units'] ?? json['otherAntihypertensivesUnits'],
      otherAntihypertensivesSpecify: json['other_antihypertensives_specify'] ?? json['otherAntihypertensivesSpecify'],
      
      // Statins
      atorvastatin5mg: json['atorvastatin_5mg'] ?? json['atorvastatin5mg'],
      atorvastatin5mgQuantity: json['atorvastatin_5mg_quantity'] ?? json['atorvastatin5mgQuantity'],
      atorvastatin5mgUnits: json['atorvastatin_5mg_units'] ?? json['atorvastatin5mgUnits'],
      atorvastatin10mg: json['atorvastatin_10mg'] ?? json['atorvastatin10mg'],
      atorvastatin10mgQuantity: json['atorvastatin_10mg_quantity'] ?? json['atorvastatin10mgQuantity'],
      atorvastatin10mgUnits: json['atorvastatin_10mg_units'] ?? json['atorvastatin10mgUnits'],
      atorvastatin20mg: json['atorvastatin_20mg'] ?? json['atorvastatin20mg'],
      atorvastatin20mgQuantity: json['atorvastatin_20mg_quantity'] ?? json['atorvastatin20mgQuantity'],
      atorvastatin20mgUnits: json['atorvastatin_20mg_units'] ?? json['atorvastatin20mgUnits'],
      otherStatins: json['other_statins'] ?? json['otherStatins'],
      otherStatinsQuantity: json['other_statins_quantity'] ?? json['otherStatinsQuantity'],
      otherStatinsUnits: json['other_statins_units'] ?? json['otherStatinsUnits'],
      otherStatinsSpecify: json['other_statins_specify'] ?? json['otherStatinsSpecify'],
      
      // Diabetes medications
      metformin500mg: json['metformin_500mg'] ?? json['metformin500mg'],
      metformin500mgQuantity: json['metformin_500mg_quantity'] ?? json['metformin500mgQuantity'],
      metformin500mgUnits: json['metformin_500mg_units'] ?? json['metformin500mgUnits'],
      metformin1000mg: json['metformin_1000mg'] ?? json['metformin1000mg'],
      metformin1000mgQuantity: json['metformin_1000mg_quantity'] ?? json['metformin1000mgQuantity'],
      metformin1000mgUnits: json['metformin_1000mg_units'] ?? json['metformin1000mgUnits'],
      glimepiride_1_2mg: json['glimepiride_1_2mg'],
      glimepiride_1_2mgQuantity: json['glimepiride_1_2mg_quantity'],
      glimepiride_1_2mgUnits: json['glimepiride_1_2mg_units'],
      gliclazide_40_80mg: json['gliclazide_40_80mg'] ?? json['gliclazide4080mg'],
      gliclazide_40_80mgQuantity: json['gliclazide_40_80mg_quantity'] ?? json['gliclazide4080mgQuantity'],
      gliclazide_40_80mgUnits: json['gliclazide_40_80mg_units'] ?? json['gliclazide4080mgUnits'],
      glipizide_2_5_5mg: json['glipizide_2_5_5mg'],
      glipizide_2_5_5mgQuantity: json['glipizide_2_5_5mg_quantity'],
      glipizide_2_5_5mgUnits: json['glipizide_2_5_5mg_units'],
      sitagliptin50mg: json['sitagliptin_50mg'] ?? json['sitagliptin50mg'],
      sitagliptin50mgQuantity: json['sitagliptin_50mg_quantity'] ?? json['sitagliptin50mgQuantity'],
      sitagliptin50mgUnits: json['sitagliptin_50mg_units'] ?? json['sitagliptin50mgUnits'],
      pioglitazone5mg: json['pioglitazone_5mg'] ?? json['pioglitazone5mg'],
      pioglitazone5mgQuantity: json['pioglitazone_5mg_quantity'] ?? json['pioglitazone5mgQuantity'],
      pioglitazone5mgUnits: json['pioglitazone_5mg_units'] ?? json['pioglitazone5mgUnits'],
      empagliflozin10mg: json['empagliflozin_10mg'] ?? json['empagliflozin10mg'],
      empagliflozin10mgQuantity: json['empagliflozin_10mg_quantity'] ?? json['empagliflozin10mgQuantity'],
      empagliflozin10mgUnits: json['empagliflozin_10mg_units'] ?? json['empagliflozin10mgUnits'],
      insulinSolubleInj: json['insulin_soluble_inj'] ?? json['insulinSolubleInj'],
      insulinSolubleInjQuantity: json['insulin_soluble_inj_quantity'] ?? json['insulinSolubleInjQuantity'],
      insulinSolubleInjUnits: json['insulin_soluble_inj_units'] ?? json['insulinSolubleInjUnits'],
      insulinNphInj: json['insulin_nph_inj'] ?? json['insulinNphInj'],
      insulinNphInjQuantity: json['insulin_nph_inj_quantity'] ?? json['insulinNphInjQuantity'],
      insulinNphInjUnits: json['insulin_nph_inj_units'] ?? json['insulinNphInjUnits'],
      otherHypoglycemicAgents: json['other_hypoglycemic_agents'] ?? json['otherHypoglycemicAgents'],
      otherHypoglycemicAgentsQuantity: json['other_hypoglycemic_agents_quantity'] ?? json['otherHypoglycemicAgentsQuantity'],
      otherHypoglycemicAgentsUnits: json['other_hypoglycemic_agents_units'] ?? json['otherHypoglycemicAgentsUnits'],
      otherHypoglycemicAgentsSpecify: json['other_hypoglycemic_agents_specify'] ?? json['otherHypoglycemicAgentsSpecify'],
      
      // Emergency and cardiovascular
      dextrose25Solution: json['dextrose_25_solution'] ?? json['dextrose25Solution'],
      dextrose25SolutionQuantity: json['dextrose_25_solution_quantity'] ?? json['dextrose25SolutionQuantity'],
      dextrose25SolutionUnits: json['dextrose_25_solution_units'] ?? json['dextrose25SolutionUnits'],
      aspirin75mg: json['aspirin_75mg'] ?? json['aspirin75mg'],
      aspirin75mgQuantity: json['aspirin_75mg_quantity'] ?? json['aspirin75mgQuantity'],
      aspirin75mgUnits: json['aspirin_75mg_units'] ?? json['aspirin75mgUnits'],
      clopidogrel75mg: json['clopidogrel_75mg'] ?? json['clopidogrel75mg'],
      clopidogrel75mgQuantity: json['clopidogrel_75mg_quantity'] ?? json['clopidogrel75mgQuantity'],
      clopidogrel75mgUnits: json['clopidogrel_75mg_units'] ?? json['clopidogrel75mgUnits'],
      metoprolol_succinate_12_5_25_50mg: json['metoprolol_succinate_12_5_25_50mg'],
      metoprolol_succinate_12_5_25_50mgQuantity: json['metoprolol_succinate_12_5_25_50mg_quantity'],
      metoprolol_succinate_12_5_25_50mgUnits: json['metoprolol_succinate_12_5_25_50mg_units'],
      isosorbideDinitrate5mg: json['isosorbide_dinitrate_5mg'] ?? json['isosorbideDinitrate5mg'],
      isosorbideDinitrate5mgQuantity: json['isosorbide_dinitrate_5mg_quantity'] ?? json['isosorbideDinitrate5mgQuantity'],
      isosorbideDinitrate5mgUnits: json['isosorbide_dinitrate_5mg_units'] ?? json['isosorbideDinitrate5mgUnits'],
      otherDrugs: json['other_drugs'] ?? json['otherDrugs'],
      otherDrugsQuantity: json['other_drugs_quantity'] ?? json['otherDrugsQuantity'],
      otherDrugsUnits: json['other_drugs_units'] ?? json['otherDrugsUnits'],
      otherDrugsSpecify: json['other_drugs_specify'] ?? json['otherDrugsSpecify'],
      
      // Antibiotics
      amoxicillinClavulanicPotassium625mg: json['amoxicillin_clavulanic_potassium_625mg'] ?? json['amoxicillinClavulanicPotassium625mg'],
      amoxicillinClavulanicPotassium625mgQuantity: json['amoxicillin_clavulanic_potassium_625mg_quantity'] ?? json['amoxicillinClavulanicPotassium625mgQuantity'],
      amoxicillinClavulanicPotassium625mgUnits: json['amoxicillin_clavulanic_potassium_625mg_units'] ?? json['amoxicillinClavulanicPotassium625mgUnits'],
      azithromycin500mg: json['azithromycin_500mg'] ?? json['azithromycin500mg'],
      azithromycin500mgQuantity: json['azithromycin_500mg_quantity'] ?? json['azithromycin500mgQuantity'],
      azithromycin500mgUnits: json['azithromycin_500mg_units'] ?? json['azithromycin500mgUnits'],
      otherAntibiotics: json['other_antibiotics'] ?? json['otherAntibiotics'],
      otherAntibioticsQuantity: json['other_antibiotics_quantity'] ?? json['otherAntibioticsQuantity'],
      otherAntibioticsUnits: json['other_antibiotics_units'] ?? json['otherAntibioticsUnits'],
      otherAntibioticsSpecify: json['other_antibiotics_specify'] ?? json['otherAntibioticsSpecify'],
      
      // Respiratory
      salbutamolDpi: json['salbutamol_dpi'] ?? json['salbutamolDpi'],
      salbutamolDpiQuantity: json['salbutamol_dpi_quantity'] ?? json['salbutamolDpiQuantity'],
      salbutamolDpiUnits: json['salbutamol_dpi_units'] ?? json['salbutamolDpiUnits'],
      salbutamol: json['salbutamol'] ?? json['salbutamol'],
      salbutamolQuantity: json['salbutamol_quantity'] ?? json['salbutamolQuantity'],
      salbutamolUnits: json['salbutamol_units'] ?? json['salbutamolUnits'],
      ipratropium: json['ipratropium'] ?? json['ipratropium'],
      ipratropiumQuantity: json['ipratropium_quantity'] ?? json['ipratropiumQuantity'],
      ipratropiumUnits: json['ipratropium_units'] ?? json['ipratropiumUnits'],
      tiotropiumBromide: json['tiotropium_bromide'] ?? json['tiotropiumBromide'],
      tiotropiumBromideQuantity: json['tiotropium_bromide_quantity'] ?? json['tiotropiumBromideQuantity'],
      tiotropiumBromideUnits: json['tiotropium_bromide_units'] ?? json['tiotropiumBromideUnits'],
      formoterol: json['formoterol'] ?? json['formoterol'],
      formoterolQuantity: json['formoterol_quantity'] ?? json['formoterolQuantity'],
      formoterolUnits: json['formoterol_units'] ?? json['formoterolUnits'],
      otherBronchodilators: json['other_bronchodilators'] ?? json['otherBronchodilators'],
      otherBronchodilatorsQuantity: json['other_bronchodilators_quantity'] ?? json['otherBronchodilatorsQuantity'],
      otherBronchodilatorsUnits: json['other_bronchodilators_units'] ?? json['otherBronchodilatorsUnits'],
      otherBronchodilatorsSpecify: json['other_bronchodilators_specify'] ?? json['otherBronchodilatorsSpecify'],
      prednisolone_5_10_20mg: json['prednisolone_5_10_20mg'] ?? json['prednisolone51020mg'],
      prednisolone_5_10_20mgQuantity: json['prednisolone_5_10_20mg_quantity'] ?? json['prednisolone51020mgQuantity'],
      prednisolone_5_10_20mgUnits: json['prednisolone_5_10_20mg_units'] ?? json['prednisolone51020mgUnits'],
      otherSteroidsOral: json['other_steroids_oral'] ?? json['otherSteroidsOral'],
      otherSteroidsOralQuantity: json['other_steroids_oral_quantity'] ?? json['otherSteroidsOralQuantity'],
      otherSteroidsOralUnits: json['other_steroids_oral_units'] ?? json['otherSteroidsOralUnits'],
      otherSteroidsOralSpecify: json['other_steroids_oral_specify'] ?? json['otherSteroidsOralSpecify'],
      
      // B2-B5 responses
      b2Response: json['b2_response'] ?? json['b2Response'],
      b2Comment: json['b2_comment'] ?? json['b2Comment'],
      b2RespondentsComment: json['b2_respondents_comment'] ?? json['b2RespondentsComment'],
      b2ValidationNote: json['b2_validation_note'] ?? json['b2ValidationNote'],
      b2RandomRecordsChecked: _parseBool(json['b2_random_records_checked'] ?? json['b2RandomRecordsChecked']),
      b2ExplanationIfNotInUse: json['b2_explanation_if_not_in_use'] ?? json['b2ExplanationIfNotInUse'],
      
      b3Response: json['b3_response'] ?? json['b3Response'],
      b3Comment: json['b3_comment'] ?? json['b3Comment'],
      b3RespondentsComment: json['b3_respondents_comment'] ?? json['b3RespondentsComment'],
      b3ValidationNote: json['b3_validation_note'] ?? json['b3ValidationNote'],
      b3ExpiryDateVerified: _parseBool(json['b3_expiry_date_verified'] ?? json['b3ExpiryDateVerified']),
      b3StorageConditionsVerified: _parseBool(json['b3_storage_conditions_verified'] ?? json['b3StorageConditionsVerified']),
      
      b4Response: json['b4_response'] ?? json['b4Response'],
      b4Comment: json['b4_comment'] ?? json['b4Comment'],
      b4RespondentsComment: json['b4_respondents_comment'] ?? json['b4RespondentsComment'],
      b4ValidationNote: json['b4_validation_note'] ?? json['b4ValidationNote'],
      b4ExpiryDateVerified: _parseBool(json['b4_expiry_date_verified'] ?? json['b4ExpiryDateVerified']),
      b4StorageConditionsVerified: _parseBool(json['b4_storage_conditions_verified'] ?? json['b4StorageConditionsVerified']),
      
      b5Response: json['b5_response'] ?? json['b5Response'],
      b5Comment: json['b5_comment'] ?? json['b5Comment'],
      b5RespondentsComment: json['b5_respondents_comment'] ?? json['b5RespondentsComment'],
      b5ValidationNote: json['b5_validation_note'] ?? json['b5ValidationNote'],
      
      // Category-specific comments
      antihypertensiveComments: json['antihypertensive_comments'] ?? json['antihypertensiveComments'],
      statinComments: json['statin_comments'] ?? json['statinComments'],
      diabetesMedicationComments: json['diabetes_medication_comments'] ?? json['diabetesMedicationComments'],
      cardiovascularMedicationComments: json['cardiovascular_medication_comments'] ?? json['cardiovascularMedicationComments'],
      respiratoryMedicationComments: json['respiratory_medication_comments'] ?? json['respiratoryMedicationComments'],
      
      // Additional tracking
      medicineQuantities: json['medicine_quantities'] ?? json['medicineQuantities'],
      expiryDatesChecked: _parseBool(json['expiry_dates_checked'] ?? json['expiryDatesChecked']),
      storageConditionsVerified: _parseBool(json['storage_conditions_verified'] ?? json['storageConditionsVerified']),
      actionsAgreed: json['actions_agreed'] ?? json['actionsAgreed'],
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (b1Response != null) 'b1_response': b1Response,
      if (b1Comment != null) 'b1_comment': b1Comment,
      if (b1RespondentsComment != null) 'b1_respondents_comment': b1RespondentsComment,
      if (b1ValidationNote != null) 'b1_validation_note': b1ValidationNote,
      
      // Antihypertensives
      if (amlodipine510mg != null) 'amlodipine_5_10mg': amlodipine510mg,
      if (amlodipine510mgQuantity != null) 'amlodipine_5_10mg_quantity': amlodipine510mgQuantity,
      if (amlodipine510mgUnits != null) 'amlodipine_5_10mg_units': amlodipine510mgUnits,
      if (enalapril2510mg != null) 'enalapril_2_5_10mg': enalapril2510mg,
      if (enalapril2510mgQuantity != null) 'enalapril_2_5_10mg_quantity': enalapril2510mgQuantity,
      if (enalapril2510mgUnits != null) 'enalapril_2_5_10mg_units': enalapril2510mgUnits,
      if (losartan2550mg != null) 'losartan_25_50mg': losartan2550mg,
      if (losartan2550mgQuantity != null) 'losartan_25_50mg_quantity': losartan2550mgQuantity,
      if (losartan2550mgUnits != null) 'losartan_25_50mg_units': losartan2550mgUnits,
      if (hydrochlorothiazide_12_5_25mg != null) 'hydrochlorothiazide_12_5_25mg': hydrochlorothiazide_12_5_25mg,
      if (hydrochlorothiazide_12_5_25mgQuantity != null) 'hydrochlorothiazide_12_5_25mg_quantity': hydrochlorothiazide_12_5_25mgQuantity,
      if (hydrochlorothiazide_12_5_25mgUnits != null) 'hydrochlorothiazide_12_5_25mg_units': hydrochlorothiazide_12_5_25mgUnits,
      if (chlorthalidone_6_25_12_5mg != null) 'chlorthalidone_6_25_12_5mg': chlorthalidone_6_25_12_5mg,
      if (chlorthalidone_6_25_12_5mgQuantity != null) 'chlorthalidone_6_25_12_5mg_quantity': chlorthalidone_6_25_12_5mgQuantity,
      if (chlorthalidone_6_25_12_5mgUnits != null) 'chlorthalidone_6_25_12_5mg_units': chlorthalidone_6_25_12_5mgUnits,
      if (otherAntihypertensives != null) 'other_antihypertensives': otherAntihypertensives,
      if (otherAntihypertensivesQuantity != null) 'other_antihypertensives_quantity': otherAntihypertensivesQuantity,
      if (otherAntihypertensivesUnits != null) 'other_antihypertensives_units': otherAntihypertensivesUnits,
      if (otherAntihypertensivesSpecify != null) 'other_antihypertensives_specify': otherAntihypertensivesSpecify,
      
      // Statins
      if (atorvastatin5mg != null) 'atorvastatin_5mg': atorvastatin5mg,
      if (atorvastatin5mgQuantity != null) 'atorvastatin_5mg_quantity': atorvastatin5mgQuantity,
      if (atorvastatin5mgUnits != null) 'atorvastatin_5mg_units': atorvastatin5mgUnits,
      if (atorvastatin10mg != null) 'atorvastatin_10mg': atorvastatin10mg,
      if (atorvastatin10mgQuantity != null) 'atorvastatin_10mg_quantity': atorvastatin10mgQuantity,
      if (atorvastatin10mgUnits != null) 'atorvastatin_10mg_units': atorvastatin10mgUnits,
      if (atorvastatin20mg != null) 'atorvastatin_20mg': atorvastatin20mg,
      if (atorvastatin20mgQuantity != null) 'atorvastatin_20mg_quantity': atorvastatin20mgQuantity,
      if (atorvastatin20mgUnits != null) 'atorvastatin_20mg_units': atorvastatin20mgUnits,
      if (otherStatins != null) 'other_statins': otherStatins,
      if (otherStatinsQuantity != null) 'other_statins_quantity': otherStatinsQuantity,
      if (otherStatinsUnits != null) 'other_statins_units': otherStatinsUnits,
      if (otherStatinsSpecify != null) 'other_statins_specify': otherStatinsSpecify,
      
      // Diabetes medications
      if (metformin500mg != null) 'metformin_500mg': metformin500mg,
      if (metformin500mgQuantity != null) 'metformin_500mg_quantity': metformin500mgQuantity,
      if (metformin500mgUnits != null) 'metformin_500mg_units': metformin500mgUnits,
      if (metformin1000mg != null) 'metformin_1000mg': metformin1000mg,
      if (metformin1000mgQuantity != null) 'metformin_1000mg_quantity': metformin1000mgQuantity,
      if (metformin1000mgUnits != null) 'metformin_1000mg_units': metformin1000mgUnits,
      if (glimepiride_1_2mg != null) 'glimepiride_1_2mg': glimepiride_1_2mg,
      if (glimepiride_1_2mgQuantity != null) 'glimepiride_1_2mg_quantity': glimepiride_1_2mgQuantity,
      if (glimepiride_1_2mgUnits != null) 'glimepiride_1_2mg_units': glimepiride_1_2mgUnits,
      if (gliclazide_40_80mg != null) 'gliclazide_40_80mg': gliclazide_40_80mg,
      if (gliclazide_40_80mgQuantity != null) 'gliclazide_40_80mg_quantity': gliclazide_40_80mgQuantity,
      if (gliclazide_40_80mgUnits != null) 'gliclazide_40_80mg_units': gliclazide_40_80mgUnits,
      if (glipizide_2_5_5mg != null) 'glipizide_2_5_5mg': glipizide_2_5_5mg,
      if (glipizide_2_5_5mgQuantity != null) 'glipizide_2_5_5mg_quantity': glipizide_2_5_5mgQuantity,
      if (glipizide_2_5_5mgUnits != null) 'glipizide_2_5_5mg_units': glipizide_2_5_5mgUnits,
      if (sitagliptin50mg != null) 'sitagliptin_50mg': sitagliptin50mg,
      if (sitagliptin50mgQuantity != null) 'sitagliptin_50mg_quantity': sitagliptin50mgQuantity,
      if (sitagliptin50mgUnits != null) 'sitagliptin_50mg_units': sitagliptin50mgUnits,
      if (pioglitazone5mg != null) 'pioglitazone_5mg': pioglitazone5mg,
      if (pioglitazone5mgQuantity != null) 'pioglitazone_5mg_quantity': pioglitazone5mgQuantity,
      if (pioglitazone5mgUnits != null) 'pioglitazone_5mg_units': pioglitazone5mgUnits,
      if (empagliflozin10mg != null) 'empagliflozin_10mg': empagliflozin10mg,
      if (empagliflozin10mgQuantity != null) 'empagliflozin_10mg_quantity': empagliflozin10mgQuantity,
      if (empagliflozin10mgUnits != null) 'empagliflozin_10mg_units': empagliflozin10mgUnits,
      if (insulinSolubleInj != null) 'insulin_soluble_inj': insulinSolubleInj,
      if (insulinSolubleInjQuantity != null) 'insulin_soluble_inj_quantity': insulinSolubleInjQuantity,
      if (insulinSolubleInjUnits != null) 'insulin_soluble_inj_units': insulinSolubleInjUnits,
      if (insulinNphInj != null) 'insulin_nph_inj': insulinNphInj,
      if (insulinNphInjQuantity != null) 'insulin_nph_inj_quantity': insulinNphInjQuantity,
      if (insulinNphInjUnits != null) 'insulin_nph_inj_units': insulinNphInjUnits,
      if (otherHypoglycemicAgents != null) 'other_hypoglycemic_agents': otherHypoglycemicAgents,
      if (otherHypoglycemicAgentsQuantity != null) 'other_hypoglycemic_agents_quantity': otherHypoglycemicAgentsQuantity,
      if (otherHypoglycemicAgentsUnits != null) 'other_hypoglycemic_agents_units': otherHypoglycemicAgentsUnits,
      if (otherHypoglycemicAgentsSpecify != null) 'other_hypoglycemic_agents_specify': otherHypoglycemicAgentsSpecify,
      
      // Emergency and cardiovascular
      if (dextrose25Solution != null) 'dextrose_25_solution': dextrose25Solution,
      if (dextrose25SolutionQuantity != null) 'dextrose_25_solution_quantity': dextrose25SolutionQuantity,
      if (dextrose25SolutionUnits != null) 'dextrose_25_solution_units': dextrose25SolutionUnits,
      if (aspirin75mg != null) 'aspirin_75mg': aspirin75mg,
      if (aspirin75mgQuantity != null) 'aspirin_75mg_quantity': aspirin75mgQuantity,
      if (aspirin75mgUnits != null) 'aspirin_75mg_units': aspirin75mgUnits,
      if (clopidogrel75mg != null) 'clopidogrel_75mg': clopidogrel75mg,
      if (clopidogrel75mgQuantity != null) 'clopidogrel_75mg_quantity': clopidogrel75mgQuantity,
      if (clopidogrel75mgUnits != null) 'clopidogrel_75mg_units': clopidogrel75mgUnits,
      if (metoprolol_succinate_12_5_25_50mg != null) 'metoprolol_succinate_12_5_25_50mg': metoprolol_succinate_12_5_25_50mg,
      if (metoprolol_succinate_12_5_25_50mgQuantity != null) 'metoprolol_succinate_12_5_25_50mg_quantity': metoprolol_succinate_12_5_25_50mgQuantity,
      if (metoprolol_succinate_12_5_25_50mgUnits != null) 'metoprolol_succinate_12_5_25_50mg_units': metoprolol_succinate_12_5_25_50mgUnits,
      if (isosorbideDinitrate5mg != null) 'isosorbide_dinitrate_5mg': isosorbideDinitrate5mg,
      if (isosorbideDinitrate5mgQuantity != null) 'isosorbide_dinitrate_5mg_quantity': isosorbideDinitrate5mgQuantity,
      if (isosorbideDinitrate5mgUnits != null) 'isosorbide_dinitrate_5mg_units': isosorbideDinitrate5mgUnits,
      if (otherDrugs != null) 'other_drugs': otherDrugs,
      if (otherDrugsQuantity != null) 'other_drugs_quantity': otherDrugsQuantity,
      if (otherDrugsUnits != null) 'other_drugs_units': otherDrugsUnits,
      if (otherDrugsSpecify != null) 'other_drugs_specify': otherDrugsSpecify,
      
      // Antibiotics
      if (amoxicillinClavulanicPotassium625mg != null) 'amoxicillin_clavulanic_potassium_625mg': amoxicillinClavulanicPotassium625mg,
      if (amoxicillinClavulanicPotassium625mgQuantity != null) 'amoxicillin_clavulanic_potassium_625mg_quantity': amoxicillinClavulanicPotassium625mgQuantity,
      if (amoxicillinClavulanicPotassium625mgUnits != null) 'amoxicillin_clavulanic_potassium_625mg_units': amoxicillinClavulanicPotassium625mgUnits,
      if (azithromycin500mg != null) 'azithromycin_500mg': azithromycin500mg,
      if (azithromycin500mgQuantity != null) 'azithromycin_500mg_quantity': azithromycin500mgQuantity,
      if (azithromycin500mgUnits != null) 'azithromycin_500mg_units': azithromycin500mgUnits,
      if (otherAntibiotics != null) 'other_antibiotics': otherAntibiotics,
      if (otherAntibioticsQuantity != null) 'other_antibiotics_quantity': otherAntibioticsQuantity,
      if (otherAntibioticsUnits != null) 'other_antibiotics_units': otherAntibioticsUnits,
      if (otherAntibioticsSpecify != null) 'other_antibiotics_specify': otherAntibioticsSpecify,
      
      // Respiratory
      if (salbutamolDpi != null) 'salbutamol_dpi': salbutamolDpi,
      if (salbutamolDpiQuantity != null) 'salbutamol_dpi_quantity': salbutamolDpiQuantity,
      if (salbutamolDpiUnits != null) 'salbutamol_dpi_units': salbutamolDpiUnits,
      if (salbutamol != null) 'salbutamol': salbutamol,
      if (salbutamolQuantity != null) 'salbutamol_quantity': salbutamolQuantity,
      if (salbutamolUnits != null) 'salbutamol_units': salbutamolUnits,
      if (ipratropium != null) 'ipratropium': ipratropium,
      if (ipratropiumQuantity != null) 'ipratropium_quantity': ipratropiumQuantity,
      if (ipratropiumUnits != null) 'ipratropium_units': ipratropiumUnits,
      if (tiotropiumBromide != null) 'tiotropium_bromide': tiotropiumBromide,
      if (tiotropiumBromideQuantity != null) 'tiotropium_bromide_quantity': tiotropiumBromideQuantity,
      if (tiotropiumBromideUnits != null) 'tiotropium_bromide_units': tiotropiumBromideUnits,
      if (formoterol != null) 'formoterol': formoterol,
      if (formoterolQuantity != null) 'formoterol_quantity': formoterolQuantity,
      if (formoterolUnits != null) 'formoterol_units': formoterolUnits,
      if (otherBronchodilators != null) 'other_bronchodilators': otherBronchodilators,
      if (otherBronchodilatorsQuantity != null) 'other_bronchodilators_quantity': otherBronchodilatorsQuantity,
      if (otherBronchodilatorsUnits != null) 'other_bronchodilators_units': otherBronchodilatorsUnits,
      if (otherBronchodilatorsSpecify != null) 'other_bronchodilators_specify': otherBronchodilatorsSpecify,
      if (prednisolone_5_10_20mg != null) 'prednisolone_5_10_20mg': prednisolone_5_10_20mg,
      if (prednisolone_5_10_20mgQuantity != null) 'prednisolone_5_10_20mg_quantity': prednisolone_5_10_20mgQuantity,
      if (prednisolone_5_10_20mgUnits != null) 'prednisolone_5_10_20mg_units': prednisolone_5_10_20mgUnits,
      if (otherSteroidsOral != null) 'other_steroids_oral': otherSteroidsOral,
      if (otherSteroidsOralQuantity != null) 'other_steroids_oral_quantity': otherSteroidsOralQuantity,
      if (otherSteroidsOralUnits != null) 'other_steroids_oral_units': otherSteroidsOralUnits,
      if (otherSteroidsOralSpecify != null) 'other_steroids_oral_specify': otherSteroidsOralSpecify,
      
      // B2-B5 responses
      if (b2Response != null) 'b2_response': b2Response,
      if (b2Comment != null) 'b2_comment': b2Comment,
      if (b2RespondentsComment != null) 'b2_respondents_comment': b2RespondentsComment,
      if (b2ValidationNote != null) 'b2_validation_note': b2ValidationNote,
      if (b2RandomRecordsChecked != null) 'b2_random_records_checked': b2RandomRecordsChecked,
      if (b2ExplanationIfNotInUse != null) 'b2_explanation_if_not_in_use': b2ExplanationIfNotInUse,
      
      if (b3Response != null) 'b3_response': b3Response,
      if (b3Comment != null) 'b3_comment': b3Comment,
      if (b3RespondentsComment != null) 'b3_respondents_comment': b3RespondentsComment,
      if (b3ValidationNote != null) 'b3_validation_note': b3ValidationNote,
      if (b3ExpiryDateVerified != null) 'b3_expiry_date_verified': b3ExpiryDateVerified,
      if (b3StorageConditionsVerified != null) 'b3_storage_conditions_verified': b3StorageConditionsVerified,
      
      if (b4Response != null) 'b4_response': b4Response,
      if (b4Comment != null) 'b4_comment': b4Comment,
      if (b4RespondentsComment != null) 'b4_respondents_comment': b4RespondentsComment,
      if (b4ValidationNote != null) 'b4_validation_note': b4ValidationNote,
      if (b4ExpiryDateVerified != null) 'b4_expiry_date_verified': b4ExpiryDateVerified,
      if (b4StorageConditionsVerified != null) 'b4_storage_conditions_verified': b4StorageConditionsVerified,
      
      if (b5Response != null) 'b5_response': b5Response,
      if (b5Comment != null) 'b5_comment': b5Comment,
      if (b5RespondentsComment != null) 'b5_respondents_comment': b5RespondentsComment,
      if (b5ValidationNote != null) 'b5_validation_note': b5ValidationNote,
      
      // Category-specific comments
      if (antihypertensiveComments != null) 'antihypertensive_comments': antihypertensiveComments,
      if (statinComments != null) 'statin_comments': statinComments,
      if (diabetesMedicationComments != null) 'diabetes_medication_comments': diabetesMedicationComments,
      if (cardiovascularMedicationComments != null) 'cardiovascular_medication_comments': cardiovascularMedicationComments,
      if (respiratoryMedicationComments != null) 'respiratory_medication_comments': respiratoryMedicationComments,
      
      // Additional tracking
      if (medicineQuantities != null) 'medicine_quantities': medicineQuantities,
      if (expiryDatesChecked != null) 'expiry_dates_checked': expiryDatesChecked,
      if (storageConditionsVerified != null) 'storage_conditions_verified': storageConditionsVerified,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  Map<String, dynamic> toServerJson() {
    return toJson(); // Since we're already handling backend field names in toJson()
  }

  LogisticsData copyWith({
    // B1 responses
    String? b1Response,
    String? b1Comment,
    String? b1RespondentsComment,
    String? b1ValidationNote,
    
    // Medicine fields
    String? amlodipine510mg,
    int? amlodipine510mgQuantity,
    String? amlodipine510mgUnits,
    String? enalapril2510mg,
    int? enalapril2510mgQuantity,
    String? enalapril2510mgUnits,
    String? losartan2550mg,
    int? losartan2550mgQuantity,
    String? losartan2550mgUnits,
    String? hydrochlorothiazide_12_5_25mg,
    int? hydrochlorothiazide_12_5_25mgQuantity,
    String? hydrochlorothiazide_12_5_25mgUnits,
    String? chlorthalidone_6_25_12_5mg,
    int? chlorthalidone_6_25_12_5mgQuantity,
    String? chlorthalidone_6_25_12_5mgUnits,
    String? otherAntihypertensives,
    int? otherAntihypertensivesQuantity,
    String? otherAntihypertensivesUnits,
    String? otherAntihypertensivesSpecify,
    String? atorvastatin5mg,
    int? atorvastatin5mgQuantity,
    String? atorvastatin5mgUnits,
    String? atorvastatin10mg,
    int? atorvastatin10mgQuantity,
    String? atorvastatin10mgUnits,
    String? atorvastatin20mg,
    int? atorvastatin20mgQuantity,
    String? atorvastatin20mgUnits,
    String? otherStatins,
    int? otherStatinsQuantity,
    String? otherStatinsUnits,
    String? otherStatinsSpecify,
    String? metformin500mg,
    int? metformin500mgQuantity,
    String? metformin500mgUnits,
    String? metformin1000mg,
    int? metformin1000mgQuantity,
    String? metformin1000mgUnits,
    String? glimepiride_1_2mg,
    int? glimepiride_1_2mgQuantity,
    String? glimepiride_1_2mgUnits,
    String? gliclazide_40_80mg,
    int? gliclazide_40_80mgQuantity,
    String? gliclazide_40_80mgUnits,
    String? glipizide_2_5_5mg,
    int? glipizide_2_5_5mgQuantity,
    String? glipizide_2_5_5mgUnits,
    String? sitagliptin50mg,
    int? sitagliptin50mgQuantity,
    String? sitagliptin50mgUnits,
    String? pioglitazone5mg,
    int? pioglitazone5mgQuantity,
    String? pioglitazone5mgUnits,
    String? empagliflozin10mg,
    int? empagliflozin10mgQuantity,
    String? empagliflozin10mgUnits,
    String? insulinSolubleInj,
    int? insulinSolubleInjQuantity,
    String? insulinSolubleInjUnits,
    String? insulinNphInj,
    int? insulinNphInjQuantity,
    String? insulinNphInjUnits,
    String? otherHypoglycemicAgents,
    int? otherHypoglycemicAgentsQuantity,
    String? otherHypoglycemicAgentsUnits,
    String? otherHypoglycemicAgentsSpecify,
    String? dextrose25Solution,
    int? dextrose25SolutionQuantity,
    String? dextrose25SolutionUnits,
    String? aspirin75mg,
    int? aspirin75mgQuantity,
    String? aspirin75mgUnits,
    String? clopidogrel75mg,
    int? clopidogrel75mgQuantity,
    String? clopidogrel75mgUnits,
    String? metoprolol_succinate_12_5_25_50mg,
    int? metoprolol_succinate_12_5_25_50mgQuantity,
    String? metoprolol_succinate_12_5_25_50mgUnits,
    String? isosorbideDinitrate5mg,
    int? isosorbideDinitrate5mgQuantity,
    String? isosorbideDinitrate5mgUnits,
    String? otherDrugs,
    int? otherDrugsQuantity,
    String? otherDrugsUnits,
    String? otherDrugsSpecify,
    // Add all other fields...
  }) {
    return LogisticsData(
      b1Response: b1Response ?? this.b1Response,
      b1Comment: b1Comment ?? this.b1Comment,
      b1RespondentsComment: b1RespondentsComment ?? this.b1RespondentsComment,
      b1ValidationNote: b1ValidationNote ?? this.b1ValidationNote,
      amlodipine510mg: amlodipine510mg ?? this.amlodipine510mg,
      amlodipine510mgQuantity: amlodipine510mgQuantity ?? this.amlodipine510mgQuantity,
      amlodipine510mgUnits: amlodipine510mgUnits ?? this.amlodipine510mgUnits,
      enalapril2510mg: enalapril2510mg ?? this.enalapril2510mg,
      enalapril2510mgQuantity: enalapril2510mgQuantity ?? this.enalapril2510mgQuantity,
      enalapril2510mgUnits: enalapril2510mgUnits ?? this.enalapril2510mgUnits,
      losartan2550mg: losartan2550mg ?? this.losartan2550mg,
      losartan2550mgQuantity: losartan2550mgQuantity ?? this.losartan2550mgQuantity,
      losartan2550mgUnits: losartan2550mgUnits ?? this.losartan2550mgUnits,
      hydrochlorothiazide_12_5_25mg: hydrochlorothiazide_12_5_25mg ?? this.hydrochlorothiazide_12_5_25mg,
      hydrochlorothiazide_12_5_25mgQuantity: hydrochlorothiazide_12_5_25mgQuantity ?? this.hydrochlorothiazide_12_5_25mgQuantity,
      hydrochlorothiazide_12_5_25mgUnits: hydrochlorothiazide_12_5_25mgUnits ?? this.hydrochlorothiazide_12_5_25mgUnits,
      chlorthalidone_6_25_12_5mg: chlorthalidone_6_25_12_5mg ?? this.chlorthalidone_6_25_12_5mg,
      chlorthalidone_6_25_12_5mgQuantity: chlorthalidone_6_25_12_5mgQuantity ?? this.chlorthalidone_6_25_12_5mgQuantity,
      chlorthalidone_6_25_12_5mgUnits: chlorthalidone_6_25_12_5mgUnits ?? this.chlorthalidone_6_25_12_5mgUnits,
      otherAntihypertensives: otherAntihypertensives ?? this.otherAntihypertensives,
      otherAntihypertensivesQuantity: otherAntihypertensivesQuantity ?? this.otherAntihypertensivesQuantity,
      otherAntihypertensivesUnits: otherAntihypertensivesUnits ?? this.otherAntihypertensivesUnits,
      otherAntihypertensivesSpecify: otherAntihypertensivesSpecify ?? this.otherAntihypertensivesSpecify,
      atorvastatin5mg: atorvastatin5mg ?? this.atorvastatin5mg,
      atorvastatin5mgQuantity: atorvastatin5mgQuantity ?? this.atorvastatin5mgQuantity,
      atorvastatin5mgUnits: atorvastatin5mgUnits ?? this.atorvastatin5mgUnits,
      atorvastatin10mg: atorvastatin10mg ?? this.atorvastatin10mg,
      atorvastatin10mgQuantity: atorvastatin10mgQuantity ?? this.atorvastatin10mgQuantity,
      atorvastatin10mgUnits: atorvastatin10mgUnits ?? this.atorvastatin10mgUnits,
      atorvastatin20mg: atorvastatin20mg ?? this.atorvastatin20mg,
      atorvastatin20mgQuantity: atorvastatin20mgQuantity ?? this.atorvastatin20mgQuantity,
      atorvastatin20mgUnits: atorvastatin20mgUnits ?? this.atorvastatin20mgUnits,
      otherStatins: otherStatins ?? this.otherStatins,
      otherStatinsQuantity: otherStatinsQuantity ?? this.otherStatinsQuantity,
      otherStatinsUnits: otherStatinsUnits ?? this.otherStatinsUnits,
      otherStatinsSpecify: otherStatinsSpecify ?? this.otherStatinsSpecify,
      metformin500mg: metformin500mg ?? this.metformin500mg,
      metformin500mgQuantity: metformin500mgQuantity ?? this.metformin500mgQuantity,
      metformin500mgUnits: metformin500mgUnits ?? this.metformin500mgUnits,
      metformin1000mg: metformin1000mg ?? this.metformin1000mg,
      metformin1000mgQuantity: metformin1000mgQuantity ?? this.metformin1000mgQuantity,
      metformin1000mgUnits: metformin1000mgUnits ?? this.metformin1000mgUnits,
      glimepiride_1_2mg: glimepiride_1_2mg ?? this.glimepiride_1_2mg,
      glimepiride_1_2mgQuantity: glimepiride_1_2mgQuantity ?? this.glimepiride_1_2mgQuantity,
      glimepiride_1_2mgUnits: glimepiride_1_2mgUnits ?? this.glimepiride_1_2mgUnits,
      gliclazide_40_80mg: gliclazide_40_80mg ?? this.gliclazide_40_80mg,
      gliclazide_40_80mgQuantity: gliclazide_40_80mgQuantity ?? this.gliclazide_40_80mgQuantity,
      gliclazide_40_80mgUnits: gliclazide_40_80mgUnits ?? this.gliclazide_40_80mgUnits,
      glipizide_2_5_5mg: glipizide_2_5_5mg ?? this.glipizide_2_5_5mg,
      glipizide_2_5_5mgQuantity: glipizide_2_5_5mgQuantity ?? this.glipizide_2_5_5mgQuantity,
      glipizide_2_5_5mgUnits: glipizide_2_5_5mgUnits ?? this.glipizide_2_5_5mgUnits,
      // Add all other fields...
    );
  }}