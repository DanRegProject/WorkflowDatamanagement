# WorkflowDatamanagement
Examples on how data management can be arranged on different levels of the data preparation proces useful for data analysis and reporting at Sundhedsdatastyrelsen and Danmarks Statistik (including OPEN).

**UpdatePDb**: SAS workflow to initate and update data on projectdatabase level with tracking of changes in previous data. Relevant if you want to keep track on changes in your datamaterial across updates.

**PrepareProjectOnPDb**: SAS workflow to extract data from the projectdatabase for a specific population and with restrictions on allowed data. Relevant if you have projectdatabase access.

**PrepareRiskScores**: SAS workflow to generate summary data for various risk scores, after data has been ported to the project. Essentially obsolete as it is included in /masterdata/.

**StudyTemplate**: SAS and Stata workflow to prepare study dataset and prepare analysis with a pdf/html report as result.

**Masterdata**:  SAS worksflow to prepare delivered data in the DS environment for subsequent studies. Ensures uniform naming of IDs, restructure and renames variables in hospital data. Also code for creating utility databases for risk scores (Charlson, HFRS, Cha2ds2-vasc etc), department types.

The suite was originally develloped in context of Aalborg Thrombosis Research Unit, Aalborg University and Unit of Thrombosis and Drug Reseach, Aalborg University Hospital, Denmark. Further refined as a part of the work in the Research Support Unit, Sygehus Lillebælt, and Inst of Regional Health, University of Southern Denmark.  Flemming Skjøth
