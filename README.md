# SA-SE Model: In Silico Model of AD Lesions with SA-SE Colonisation

This repository contains the code for reproducing the results from: "In Silico Elucidation of Key Drivers of Staphylococcus aureus-Staphylococcus epidermidis-Induced Skin Damage in Atopic Dermatitis Lesions".

## 📄 Publication

**Paper**: Lee, J, Mannan, AA, Miyano, T, Irvine AD, Tanaka RJ. In Silico Elucidation of Key Drivers of Staphylococcus aureus-Staphylococcus epidermidis-Induced Skin Damage in Atopic Dermatitis Lesions. JID Innov 2024;4:100269.

**DOI**: [10.1016/j.xjidi.2024.100269](https://doi.org/10.1016/j.xjidi.2024.100269)

## 📋 Table of Contents

1. [Quick Start](#-quick-start)
2. [Figure Generation](#-figure-generation)
3. [Repository Structure](#-repository-structure)
4. [Complete Workflow](#-complete-workflow)
5. [Data Specifications](#-data-specifications)
6. [Contact](#-contact)
7. [License](#-license)

## 🚀 Quick Start

### Prerequisites

**Software Requirements:**
- MATLAB R2021b or later
- Statistics and Machine Learning Toolbox (for violin plots)
- Parallel Computing Toolbox

**Hardware Recommendations:**
- **RAM**: 4 GB minimum, 16 GB recommended for full workflow
- **Storage**: ~5 GB for all data files
- **Runtime**: ~24 hours for complete analysis (steady state analysis takes ~7 hours)

### Installation

```bash
# Clone the repository
git clone https://github.com/username/SASE-model.git
cd SASE-model
```

### Minimal Working Example to Generate Key Figures

Once cloned, follow these steps to reproduce the key figures from the paper:

#### Step 1: Generate Virtual Skin Site Dataset
```matlab
% Navigate to core analysis folder
cd 'Analyse steady states'

% Run complete steady state analysis (~7 hours)
run run_SteadyStates.m
```

**Output**: `AllVirtualPatientTypes_latest.csv` 
- Contains 1 million virtual skin sites with steady states analysed
- Each row contains 26 columns: patient ID, number of steady states, 17 sampled parameters (A<sub>max</sub> and E<sub>max</sub> are fixed at default values), and 7 computed values (3 steady state values, 3 eigenvalues, 1 region classification).

**More info**: Please refer to [Data Specifications](#📊-data-specifications) for the complete 26 column description and region classification rules.

---

#### Step 2: Visualise Steady State Subtypes → Figure 2, Supplementary Figure S1
```matlab
% Navigate to sub-type visualisation folder
cd '../Group virtual skin sites'

% Generate steady state subtype plots
run run_patient_types.m
```

**Outputs**: Phase portraits showing SA (x-axis) vs SE (y-axis) populations at steady state, colored by barrier integrity (yellow = undamaged, red = damaged)

- `PatientTypes_1_SteadyState.png` - Sites with 1 steady state (8 subplots)
- `PatientTypes_2_SteadyStates.png` - Sites with 2 steady states (21 subplots)
- `PatientTypes_3_SteadyStates.png` - Sites with 3 steady states (19 subplots)

**Figures**: 
- **Supplementary Figure S1**: Uses subplots from the three generated files above (subplots were manually rearranged for publication)
- **Figure 2**: Characterisation of three main skin types (Asymptomatic, Reversible, Irreversible) based on this analysis

---

#### Step 3: Treatment Simulations → Figure 3b-d, Supplementary Figures S2-S3
```matlab
% Navigate to SA-killing treatment folder
cd '../Effect of SA-killing'

% Explore effect of SA-killing treatment
run run_SA_killing_main.m % generates Figure 3b - d in main text
run run_SA_killing_supplementary.m % generates Figure S2 in supplementary materials
run run_SA_killing_example_site.m % generates Figure S3 in supplementary materials 
```

**Outputs**:

**Treatment strength varied between 0-5 days<sup>-1</sup> and 1-4 days**
- `Figure3_AllSites.png` - Treatment response for all virtual skin sites with a damaged skin state
- `Figure3_Irreversible.png` - Treatment response for irreversible sites
- `Figure3_Reversible.png` - Treatment response for reversible sites

**Treatment strength varied between 0-10 days<sup>-1</sup> and 2-50 days**
- `FigureS2_AllSites.png` - Treatment response for all virtual skin sites with a damaged skin state
- `FigureS2_Irreversible.png` - Treatment response for irreversible sites
- `FigureS2_Reversible.png` - Treatment response for reversible sites

**Treatment response for one example virtual skin site**
- `FigureS3_PhasePortrait.png` - SA and SE population sizes for one example virtual skin site
- `FigureS3_TreatmentResponse.png` - Treatment response for one example virtual skin site

**Figures**:
- **Figure 3b-d**: (b) `Figure3_AllSites.png`, (c) `Figure3_Irreversible.png`, and (d) `Figure3_Reversible.png`
- **Supplementary Figure S2**: (a) `FigureS2_AllSites.png`, (b) `FigureS2_Irreversible.png`, and (c) `FigureS2_Reversible.png`
- **Supplementary Figure S3**: (a) `FigureS3_PhasePortrait.png` and (b) `FigureS3_TreatmentResponse.png`

---

#### Step 4: Parameter Distribution Analysis → Figure 4a, Supplementary Figures S4-S5
```matlab
% Navigate to violin plots folder
cd '../Violin plots'

% Generate all parameter distribution plots
run run_violin_analysis('generate_all', true)
```

**Outputs**: Violin plots comparing 15 parameter distributions (A<sub>max</sub> and E<sub>max</sub> are fixed at 1.11×10⁹) across patient types (asymptomatic, reversible, irreversible)

- `ViolinPlots_all.png` - All virtual skin sites
- `ViolinPlots_damage.png` - Only sites with skin-damaging SE strains (δ<sub>BE</sub> > 0)
- `ViolinPlots_no_damage.png` - Only sites without skin-damaging SE strains (δ<sub>BE</sub> = 0)

**Figures**: 
- **Figure 4a**: Highlights 6 key parameters from `ViolinPlots_all.png` (subset of parameters selected by visual inspection)
- **Supplementary Figure S4**: Complete parameter distributions from `ViolinPlots_all.png`
- **Supplementary Figure S5a**: Parameter distributions for damaging SE strains (from `ViolinPlots_damage.png`)
- **Supplementary Figure S5b**: Parameter distributions for non-damaging SE strains (from `ViolinPlots_no_damage.png`)

---

#### Step 5: Proposed Treatment Strategy → Figure 5, Supplementary Figure S6
```matlab
% Navigate to dual-action treatment folder
cd '../Effect of dual-action treatment'

% Explore effect of dual-action treatment
run run_DualAction.m % generates Figure 5b - d in main text
run run_AttenuationOnly_supplementary.m % generates Figure S6b - d in supplementary materials
```

**Outputs**:

**SA-killing strength varied between 0-5 days<sup>-1</sup> and 1-4 days with 20-fold attenuation on SA and SE growths**
- `Figure5_AllSites.png` - Treatment response for all virtual skin sites with a damaged skin state
- `Figure5_Irreversible.png` - Treatment response for irreversible sites
- `Figure5_Reversible.png` - Treatment response for reversible sites

**SA and SE growth attenuation varied between 1- and 20-fold**
- `FigureS6_AttenuationHeatmaps.png` - Proportion of virtual skin sites that gain an undamaged skin state

**Figures**:
- **Figure 5b-d**: (b) `Figure5_AllSites.png`, (c) `Figure5_Irreversible.png`, and (d) `Figure5_Reversible.png`
- **Supplementary Figure S6b-d**: `FigureS6_AttenuationHeatmaps.png`

## 🎨 Figure Generation

### Main Text Figures

| Figure | Scripts | Folder | Description |
|--------|---------|--------|-------------|
| **Figure 2** | `run_steady_state_plots.m` | Group virtual skin sites | Illustration of three types of virtual skin sites defined by whether the stable skin state converged to undamaged or damaged |
| **Figure 3b-d** | `run_SA_killing_main.m` | Effect of SA-killing | Proportion of all damaged skin sites that recover to an undamaged skin state |
| **Figure 4a** | `run_violin_analysis.m` | Violin plots | Parameter distributions by patient type |
| **Figure 5b-d** | `run_DualAction.m` | Effect of dual-action treatment | Proportion of all damaged skin sites that recover to an undamaged skin state |

### Supplementary Figures

| Figure | Scripts | Folder | Description |
|--------|---------|--------|-------------|
| **Figure S1** | `run_steady_state_plots.m` | Group virtual skin sites | Phase portraits by steady state count |
| **Figure S2** | `run_SA_killing_supplementary.m` | Effect of SA-killing | Success of SA-killing for longer and stronger treatments |
| **Figure S3** | `run_example_supplementary.m` | Effect of SA-killing | SA-killing applied to one example skin site |
| **Figure S4** | `run_violin_analysis.m` | Violin plots | Distribution of parameters driving asymptomatic, reversible, and irreversible skin sites |
| **Figure S5** | `run_violin_analysis.m` | Violin plots | Distribution of parameters for sites with (a) non-damaging and (b) damaging SE strains |
| **Figure S6b-d** | `run_AttenuationOnly_supplementary.m` | Effect of dual-action treatment | Percentage of sites that gain a non-damaged state when SA and SE growth attenuation is enhanced by different strengths |


## 📁 Repository Structure

```
SASE-model/
├── Analyse steady states/          # Key workflow: Generate & classify patients
│   ├── run_SteadyStates.m          # Main entry point
│   └── data/
│       ├── asymp.csv               # Asymptomatic skin sites
│       ├── reversible.csv          # Reversible skin sites
│       ├── irreversible.csv        # Irreversible skin sites
│       └── AllVirtualPatientTypes_latest.csv   # Key output
│
├── Group virtual skin sites/       # Visualise virtual skin sites by steady states observed
│   ├── run_patient_types.m         # Plots sub-categories of virtual skin sites   
│   ├── data/                       # AllVirtualPatientTypes_latest.csv grouped into 1, 2, 3 steady states
│   │   ├── One_StableState.csv         
│   │   ├── Two_StableState.csv
│   │   └── Three_StableState.csv
│   └── figures/                    
│       ├── PatientTypes_1_SteadyState.png   
│       ├── PatientTypes_2_SteadyStates.png
│       └── PatientTypes_3_SteadyStates.png
│
├── Effect of SA-killing/                   # SA-killing treatment analysis
│   ├── run_SA_killing_main.m               # Generates Figure 3b-d in paper   
│   ├── run_SA_killing_supplementary.m      # Generates Figure S2 in paper  
│   ├── run_example_supplementary.m         # Generates Figure S3 in paper   
│   ├── data/                               # Treatment results
│   │   ├── irreversible_SAkilling.csv      # Initial conditions for treatment simulations for irreversible sites   
│   │   ├── reversible_SAkilling.csv        # Initial conditions for treatment simulations for reversible sites
│   │   ├── reversible_treatment_results_main.csv  # Treatment success for reversible sites
│   │   ├── reversible_treatment_results_supp.csv  # Treatment success for reversible sites
│   │   └── example_site_results.csv               # Treatment success for example site
│   └── figures/                    
│       ├── Figure3_AllSites.png
│       ├── Figure3_Irreversible.png
│       ├── Figure3_Reversible.png
│       ├── FigureS2_AllSites.png
│       ├── FigureS2_Irreversible.png
│       ├── FigureS2_Reversible.png
│       ├── FigureS3_PhasePortrait.png
│       └── FigureS3_TreatmentResponse.png
│
├── Violin plots/                   # Parameter distribution analysis
│   ├── run_violin_analysis.m       # Generate violin plots
│   └── figures/                    
│       ├── ViolinPlots_all.png    
│       ├── ViolinPlots_SE_damaging.png
│       └── ViolinPlots_SE_nondamaging.png
│
├── Effect of dual-action treatment/ # Dual-action treatment analysis
│   ├── run_DualAction.m                                    # Generates Figure 5b-d in paper   
│   ├── run_AttenuationOnly_supplementary.m                 # Generates Figure S6b-d in paper  
│   ├── data/                                               
│   │   ├── attenuation_irreversible_SA20.0_SE20.0.csv      # Steady states after 20-fold attenuation
│   │   ├── attenuation_reversible_SA20.0_SE20.0.csv        # Steady states after 20-fold attenuation
│   │   ├── irreversible_SAkilling_post_attenuation.csv     # Initial conditions for treatment simulations for irreverisble sites
│   │   ├── reversible_SAkilling_post_attenuation.csv       # Initial conditions for treatment simulations for reverisble sites
│   │   ├── irreversible_treatment_results_dual_action.csv  # Treatment results
│   │   └── reversible_treatment_results_dual_action.csv    # Treatment results
│   └── figures/                    
│       ├── Figure5_AllSites.png
│       ├── Figure5_Irreversible.png
│       ├── Figure5_Reversible.png
│       └── FigureS6_AttenuationHeatmaps.png
└── README.md                       # This file
```

### Script Naming Convention

- **`g_*.m`** - **Generate** data files (e.g., parameter sets, CSVs)
- **`a_*.m`** - **Analyse** existing data (e.g., steady states, classifications)
- **`f_*.m`** - **Function** definitions (helper functions)
- **`run_*.m`** - **Runner** scripts (orchestrate workflows)

## 🔄 Complete Workflow

### Overview

The analysis pipeline consists of five main stages:

```
[1] Generate & classify → [2] Visualise steady states → [3] Simulate effect of SA-killing treatment → [4] Analyse parameter distributions → [5] Simulate dual-action treatment
```

## Stage 1: Generate and Classify Virtual Patients

**Location**: `Analyse steady states/`

**Purpose**: Generate 1 million virtual patient parameter sets, compute their steady states, and classify them into clinical categories. This is the foundational analysis that provides input data for all downstream analyses (visualisations, treatment simulations, parameter distributions).

### File Organisation:

### 🚀 Main Runner Script (Orchestrates Complete Pipeline)

| Script | Purpose | Key Configuration Options | Outputs |
|-------|---------|----------------------|---------|
| **`run_SteadyStates.m`** | Execute complete steady state analysis pipeline | `n_samples`, `random_seed` | `AllVirtualPatientTypes_latest.csv` and all intermediate files |

### 🔧 Core Analysis Functions (Called Automatically)

| Script | Purpose | Used By |
|----------|---------|---------|
| **`g_Samples.m`** | Generate parameter samples from log-uniform distributions<br/>**Input**: Configuration parameters<br/>**Output**: `SampledParameters_[date].csv` (17 columns) | Step 1 in `run_SteadyStates.m` |
| **`a_SampledParameters.m`** | Compute steady states across 4 biological scenarios<br/>**Input**: `SampledParameters_latest.csv`<br/>**Output**: `AllSteadyStates_[date].csv` (23 columns) | Step 2 in `run_SteadyStates.m` |
| **`g_VirtualPatients.m`** | Group by number of steady states and assign patient IDs<br/>**Input**: `AllSteadyStates_latest.csv`<br/>**Output**: `AllVirtualPatients_[date].csv` (25 columns) | Step 3 in `run_SteadyStates.m` |
| **`a_PatientGroups.m`** | Classify patients into 9 clinical categories<br/>**Input**: `AllVirtualPatients_latest.csv`<br/>**Output**: `AllVirtualPatientTypes_[date].csv` (26 columns) | Step 4 in `run_SteadyStates.m` |
| **`g_ClassificationFiles.m`** | Generate CSV files for downstream analyses<br/>**Input**: `AllVirtualPatientTypes_latest.csv`<br/>**Output**: `asymp.csv`, `reversible.csv`, `irreversible.csv` | Step 5 in `run_SteadyStates.m` |

### 📊 Mathematical Functions (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`f_defineODEs.m`** | Define coupled ODE system for SA-SE-Barrier dynamics | `a_SampledParameters.m` |
| **`f_computeCase1.m`** | Compute steady states when both SA and SE agr are inactive | `a_SampledParameters.m` |
| **`f_computeCase2.m`** | Compute steady states when SA agr active, SE agr inactive | `a_SampledParameters.m` |
| **`f_computeCase3.m`** | Compute steady states when SA agr inactive, SE agr active | `a_SampledParameters.m` |
| **`f_computeCase4.m`** | Compute steady states when both SA and SE agr are active | `a_SampledParameters.m` |
| **`f_SteadyStateCheck.m`** | Validate computed steady states and calculate eigenvalues | `g_VirtualPatients.m` |

### Workflow:

```
Complete workflow:
run_SteadyStates.m
├── Step 1: g_Samples.m
│   ├── Set random seed for reproducibility
│   ├── Sample 1M parameter sets from log-uniform distributions
│   └── Save: SampledParameters_[date].csv (1M rows × 17 columns)
│
├── Step 2: a_SampledParameters.m
│   ├── For each parameter set, compute steady states across 4 scenarios:
│   │   ├── Case 1: Both agr switches OFF (low bacterial loads)
│   │   ├── Case 2: SA agr ON, SE agr OFF (SA dominance)
│   │   ├── Case 3: SA agr OFF, SE agr ON (SE dominance)
│   │   └── Case 4: Both agr switches ON (SA-SE co-existence)
│   ├── Calculate stability eigenvalues for each steady state
│   └── Save: AllSteadyStates_[date].csv (23 columns)
│
├── Step 3: g_VirtualPatients.m
│   ├── Group steady states by unique parameter sets (Patient ID)
│   ├── Filter for stable states only (negative eigenvalues)
│   ├── Count number of stable states per patient (1, 2, or 3)
│   └── Save: AllVirtualPatients_[date].csv (~1M patients × 25 columns)
│
├── Step 4: a_PatientGroups.m
│   ├── Classify each patient into 9 clinical categories based on:
│   │   ├── Bacterial population levels (SA*, SE*)
│   │   ├── Barrier integrity status (B*)
│   │   └── Quorum sensing threshold relationships
│   └── Save: AllVirtualPatientTypes_[date].csv (~1M patients × 26 columns)
│
└── Step 5: g_ClassificationFiles.m
    ├── Separate patients by barrier status across ALL steady states:
    │   ├── Asymptomatic: ALL steady states have B* = 1
    │   ├── Reversible: MIX of B* = 1 and B* < 1 states
    │   └── Irreversible: ALL steady states have B* < 1
    └── Save: asymp.csv, reversible.csv, irreversible.csv
```

### Output Files:

### Primary Output (Used by All Downstream Analyses)
- **`data/AllVirtualPatientTypes_latest.csv`** - Complete virtual patient dataset (~1M patients × 26 columns)
  - **Column 1**: Patient ID (1 to 10⁶)
  - **Column 2**: Number of stable steady states (1, 2, or 3)
  - **Columns 3-19**: Model parameters (17 parameters from Supplementary Table S1)
  - **Columns 20-22**: Steady state values (SA*, SE*, B*)
  - **Columns 23-25**: Stability eigenvalues (λ₁, λ₂, λ₃)
  - **Column 26**: Clinical category/region (1-9)
- Please refer to [Data Specifications](#📊-data-specifications) for a more detailed breakdown.

### Intermediate Processing Files
- **`data/SampledParameters_[date].csv`** - Raw parameter samples (1M sets × 17 columns)
- **`data/AllSteadyStates_[date].csv`** - All computed steady states (~4M states × 23 columns)
- **`data/AllVirtualPatients_[date].csv`** - Grouped by patient ID (1M patients × 25 columns)

### Classification Files (For Downstream Analyses)
- **`data/asymp.csv`** - Asymptomatic patients (ALL states B* = 1)
- **`data/reversible.csv`** - Reversible patients (MIX of B* = 1 and B* < 1)
- **`data/irreversible.csv`** - Irreversible patients (ALL states B* < 1)

### Versioned Archives
- **`data/*_latest.csv`** - Symbolic links to most recent analysis
- **`data/*_[date].csv`** - Date-stamped archives for reproducibility
- **`data/*_[date].mat`** - MATLAB format for faster loading (optional)

## Stage 2: Visualise Virtual Skin Sites by Steady State Count

**Location**: `Group virtual skin sites/`

**Purpose**: Generate phase portrait plots of virtual skin sites organised by the number of stable steady states they possess. Creates figures showing SA vs SE populations at steady state, grouped by region combinations and colored by barrier integrity status (red = damaged, yellow = undamaged).

### File Organisation:

### 🚀 Main Runner Script (Single Entry Point)

| Usage | Purpose | Outputs |
|-------|---------|---------|
| **`run_patient_types.m`** | Generate all steady state visualisations | All CSV files and PNG figures |

### 🔧 Core Analysis Functions (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`g_PatientTypes_1.m`** | Generate patient visualisations for patients with 1 steady state<br/>**Input**: `AllVirtualPatientTypes_latest.csv`<br/>**Output**: `PatientTypes_1_SteadyState.png` (8 region categories) | `run_patient_types.m` |
| **`g_PatientTypes_2.m`** | Generate patient visualisations for patients with 2 steady states<br/>**Input**: `AllVirtualPatientTypes_latest.csv`<br/>**Output**: `PatientTypes_2_SteadyStates.png` (21 region combinations) | `run_patient_types.m` |
| **`g_PatientTypes_3.m`** | Generate patient visualisations for patients with 3 steady states<br/>**Input**: `AllVirtualPatientTypes_latest.csv`<br/>**Output**: `PatientTypes_3_SteadyStates.png` (19 region combinations) | `run_patient_types.m` |

### Workflow:

```
Prerequisites:
├── ../Analyse steady states/data/AllVirtualPatientTypes_latest.csv ✅ 

Complete Workflow:
run_patient_types.m
├── Step 1: g_PatientTypes_1.m
│   ├── Filter patients with 1 steady state → data/One_StableState.csv
│   ├── Group by 8 region categories (1,2,3,4,5,6,7,8/9)
│   └── Generate 2×4 subplot figure → figures/PatientTypes_1_SteadyState.png
│
├── Step 2: g_PatientTypes_2.m
│   ├── Filter patients with 2 steady states → data/Two_StableStates.csv
│   ├── Group by region combinations (21 pairs in total)
│   └── Generate multi-subplot figure → figures/PatientTypes_2_SteadyStates.png
│
└── Step 3: g_PatientTypes_3.m
    ├── Filter patients with 3 steady states → data/Three_StableStates.csv
    ├── Group by all detected region combinations (19 region combinations)
    └── Generate dynamic subplot figure → figures/PatientTypes_3_SteadyStates.png
```

### Output Files:

### Data Files (Intermediate Processing)
- `data/One_StableState.csv` - Patients with exactly 1 stable steady state (asymptomatic or irreversible)
- `data/Two_StableStates.csv` - Patients with exactly 2 stable steady states (reversible or irreversible)
- `data/Three_StableStates.csv` - Patients with exactly 3 stable steady states (always reversible)

### Figure Files
- `figures/PatientTypes_1_SteadyState.png` - Supplementary: Single steady state phase portraits (Supplementary Figure S1, 8 subplots)
- `figures/PatientTypes_2_SteadyStates.png` - Supplementary: Two steady state combinations (Supplementary Figure S1, 21 subplots)  
- `figures/PatientTypes_3_SteadyStates.png` - Supplementary: Three steady state combinations (Supplementary Figure S1, variable subplots)

## Stage 3: Apply SA-killing treatment

**Location**: `Effect of SA-killing/`

**Purpose**: Analyse SA-killing treatment effectiveness on virtual patients with damaged skin barrier. Focuses specifically on reversible and irreversible skin sites.

### File Organisation:

### 🚀 Main Runner Scripts (Entry Points)

| Script | Purpose | Parameters | Outputs |
|--------|---------|------------|---------|
| **`run_SA_killing_main.m`** | Generate Figure 3b-d | Strength 0-5, Duration 1-4 days | `Figure3_AllSites.png`, `Figure3_Reversible.png`, `Figure3_Irreversible.png` |
| **`run_SA_killing_supplementary.m`** | Generate Supplementary Figure S2 | Strength 0-10, Duration 2-50 days | `FigureS2_AllSites.png`, `FigureS2_Reversible.png`, `FigureS2_Irreversible.png` |
| **`run_example_supplementary.m`** | Generate Supplementary Figure S3 | Single patient analysis | `FigureS3_PhasePortrait.png`, `FigureS3_TreatmentResponse.png` |

### 🔧 Core Analysis Functions (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`g_ExtractInitialConditions.m`** | Extract worst-case initial conditions for treatment simulations (see Materials and Methods in paper) | `run_SA_killing_main.m`, `run_SA_killing_supplementary.m` |
| **`g_TreatmentResponse.m`** | Run SA-killing treatment grid simulations<br/>**Input**: `data/reversible_SAkilling.csv`<br/>**Output**: `data/reversible_treatment_results_[suffix].csv`<br/>*Suffix: 'main' or 'supp' to prevent overwriting* | `run_SA_killing_main.m`, `run_SA_killing_supplementary.m` |

### 📊 Visualisation Functions (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`g_Plot_Main.m`** | Generate main text heatmaps with contour lines (Figure 3b-d) | `run_SA_killing_supplementary.m` |
| **`g_Plot_Supplementary.m`** | Generate supplementary heatmaps with exact values (Supplementary Figure S2) | `run_SA_killing_main.m` |
| **`g_VisualiseExampleSites.m`** | Generate phase portrait plot (Supplementary Figure S3a) | `run_example_supplementary.m` |
| **`g_ExampleSiteAnalysis.m`** | Generate treatment response plot for a single patient (Supplementary Figure S3b) | `run_example_supplementary.m` |

### ⚙️ Mathematical Functions (Called Automatically)

| Function | Purpose |
|----------|---------|
| **`f_defineODEs.m`** | ODEs defining mathematical model |
| **`f_defineODEs_SAkilling.m`** | ODEs with SA-killing term |
| **`f_EventHealthy.m`** | Event detection for when a healthy state (B* = 1) is reached |

### Workflow:

```
Prerequisites:
├── ../Analyse steady states/data/reversible.csv ✅ 
├── ../Analyse steady states/data/irreversible.csv ✅ 

Main Text Workflow (Figure 3b-d):
run_SA_killing_main.m
├── g_ExtractInitialConditions.m → data/reversible_SAkilling.csv, data/irreversible_SAkilling.csv
├── g_TreatmentResponse.m → data/reversible_treatment_results.csv
└── g_Plot_Main.m → figures/Fig3_AllSites.png, Fig3_Reversible.png, Fig3_Irreversible.png

Supplementary Workflow (Figure S2):
run_SA_killing_supplementary.m  
├── [Same extraction and treatment steps with different parameters]
└── g_Plot_Supplementary.m → figures/FigS2_AllSites.png, FigS2_Reversible.png, FigS2_Irreversible.png

Example Site Workflow (Figure S3):
run_example_supplementary.m
├── g_VisualiseExampleSites.m → figures/FigS3_PhasePortrait.png
└── g_ExampleSiteAnalysis.m → figures/FigS3_TreatmentResponse.png
```

### Output Files:

### Data Files
- `data/reversible_SAkilling.csv` - Initial conditions for reversible patients
- `data/irreversible_SAkilling.csv` - Initial conditions for irreversible patients
- `data/reversible_treatment_results.csv` - Treatment simulation results grid
- `data/example_site_results.csv` - Single patient detailed analysis results

### Figure Files
- `figures/Figure3_AllSites.png` - Main text: Combined treatment response heatmap
- `figures/Figure3_Reversible.png` - Main text: Reversible patients treatment response
- `figures/Figure3_Irreversible.png` - Main text: Irreversible patients treatment response
- `figures/FigureS2_AllSites.png` - Supplementary: Extended parameter range heatmap (combined)
- `figures/FigureS2_Reversible.png` - Supplementary: Extended parameter range (reversible)
- `figures/FigureS2_Irreversible.png` - Supplementary: Extended parameter range (irreversible)
- `figures/FigureS3_PhasePortrait.png` - Supplementary: Single patient phase portrait
- `figures/FigureS3_TreatmentResponse.png` - Supplementary: Single patient treatment response

## Stage 4: Analyse Parameter Distributions

**Location**: `Violin plots/`

**Purpose**: Visualise parameter distributions across different patient types using violin plots. Provides three distinct filtering modes to examine how 15 model parameters vary between asymptomatic, reversible, and irreversible patient groups with a focus on SE strain characteristics.

### File Organisation:

### 🚀 Main Runner Scripts (Single Entry Point)

| Usage | Purpose | Parameters | Outputs |
|--------|---------|------------|---------|
| **`run_violin_analysis()`** | Interactive mode with guided prompts | User prompts for mode and CSV options | Selected analysis based on user choice |
| **`run_violin_analysis('all')`** | Generate Figures 4a and S4 | All patients, 15 parameters | `ViolinPlots_all.png` |
| **`run_violin_analysis('SE_damaging')`** | Generate Supplementary Figure S5a | SE-damaging strains only (δ_BE > 0) | `ViolinPlots_SE_damaging.png` |
| **`run_violin_analysis('SE_nondamaging')`** | Generate Supplementary Figure S5b | SE-nondamaging strains only (δ_BE = 0) | `ViolinPlots_SE_nondamaging.png` |
| **`run_violin_analysis('generate_all')`** | Generate all figures at once | All three analysis modes | All three PNG files |

### 🔧 Core Analysis Functions (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`g_violin_plot.m`** | Core plotting function with SE strain filtering<br/>**Input**: `../Analyse steady states/data/*.csv`<br/>**Output**: Violin plots | All `run_violin_analysis` modes |
| **`prepare_parameter_data()`** | Helper function to format data for violin plots<br/>Handles log transformation and NaN padding for unequal group sizes | `g_violin_plot.m` |

### 📊 Violin Plot Implementation (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`violinplot.m`** | User-friendly wrapper for creating violin plots with customisation options. Downloaded from Holger Hoffmann (2025). Violin Plot (https://www.mathworks.com/matlabcentral/fileexchange/45134-violin-plot), MATLAB Central File Exchange. Retrieved October 17, 2025. | `g_violin_plot.m` |
| **`Violin.m`** | Downloaded from Holger Hoffmann (2025). Violin Plot (https://www.mathworks.com/matlabcentral/fileexchange/45134-violin-plot), MATLAB Central File Exchange. Retrieved October 17, 2025. | `violinplot.m` |

### ⚙️ Data Management Functions (Called Automatically)

| Function | Purpose |
|----------|---------|
| **`g_ClassificationFiles.m`** | Generates asymp.csv, reversible.csv, irreversible.csv from AllVirtualPatientTypes_latest.csv |

### Workflow:

```
Prerequisites:
├── ../Analyse steady states/data/AllVirtualPatientTypes_latest.csv ✅ 
├── ../Analyse steady states/g_ClassificationFiles.m ✅ 

Interactive Workflow:
run_violin_analysis()
├── Check for CSV files → Generate if missing via g_ClassificationFiles.m
├── User selects analysis mode (1-4)
└── g_violin_plot(mode) → figures/ViolinPlots_[mode].png

Batch Workflow (All figures):
run_violin_analysis('generate_all')
├── Check/generate CSV files automatically
├── g_violin_plot('all') → figures/ViolinPlots_all.png
├── g_violin_plot('SE_damaging') → figures/ViolinPlots_SE_damaging.png
└── g_violin_plot('SE_nondamaging') → figures/ViolinPlots_SE_nondamaging.png

Single Mode Workflow:
run_violin_analysis('all', false)
├── Use existing CSV files (no regeneration)
└── g_violin_plot('all') → figures/ViolinPlots_all.png
```

### Output Files:

### Data Files (Auto-generated if missing)
- `../Analyse steady states/data/asymp.csv` - Asymptomatic patient parameters (all steady states have B* = 1)
- `../Analyse steady states/data/reversible.csv` - Reversible patient parameters (mixed B* = 1 and B* < 1 states)
- `../Analyse steady states/data/irreversible.csv` - Irreversible patient parameters (all steady states have B* < 1)

### Figure Files
- `figures/ViolinPlots_all.png` - Main text: Complete parameter comparison across all patient types (Figure 4a source)
- `figures/ViolinPlots_SE_damaging.png` - Supplementary: SE-damaging strain analysis (Supplementary Figure S5a)
- `figures/ViolinPlots_SE_nondamaging.png` - Supplementary: SE-non-damaging strain analysis (Supplementary Figure S5b)

## Stage 5: Dual-action treatment strategy

**Location**: `Effect of dual-action treatment/`

**Purpose**: Analyse combined SA- and SE-attenuation and SA-killing treatment effectiveness on virtual patients.

### File Organisation:

### 🚀 Main Runner Scripts (Entry Points)

| Script | Purpose | Parameters | Outputs |
|--------|---------|------------|---------|
| **`run_DualAction.m`** | Generate Figure 5b-d | 20× SA- and SE-attenuation + SA-killing (0-5 strength, 1-4 days) | `DualAction_Heatmap.png`, treatment CSV files |
| **`run_AttenuationOnly_supplementary.m`** | Generate Supplementary Figure S6b-d | SA- and SE-attenuation grid (1×, 10×, 20×) | `FigureS6_AttenuationHeatmaps.png`, attenuation CSV files |

### 🔧 Core Analysis Functions (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`g_AttenuationFlexible.m`** | Apply attenuation enhancement to bacterial growth rates<br/>**Input**: Patient CSV files<br/>**Output**: Post-attenuation steady states | `run_DualAction.m`, `run_AttenuationOnly_supplementary.m` |
| **`g_TreatmentResponse_DualAction.m`** | Run SA-killing treatment on attenuated patients<br/>**Input**: `data/[patient_type]_SAkilling_post_attenuation.csv`<br/>**Output**: Dual-action treatment results | `run_DualAction.m` |

### 📊 Visualisation Functions (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`g_Plot_DualAction.m`** | Generate dual-action treatment heatmaps (Figure 5b-d) | `run_DualAction.m` |
| **`g_Plot_AttenuationOnly.m`** | Generate attenuation-only heatmaps (Supplementary Figure S6b-d) | `run_AttenuationOnly_supplementary.m` |

### ⚙️ Mathematical Functions (Called Automatically)

| Function | Purpose |
|----------|---------|
| **`f_defineODEs.m`** | ODEs defining mathematical model |
| **`f_defineODEs_SAkilling.m`** | ODEs with SA-killing term |
| **`f_EventHealthy.m`** | Event detection for when a healthy state (B* = 1) is reached |

### Workflow:

```
Prerequisites:
├── ../Effect of SA-killing/data/reversible_SAkilling.csv ✅ 
├── ../Effect of SA-killing/data/irreversible_SAkilling.csv ✅ 

Dual-Action Workflow (Figure 5b-d):
run_DualAction.m
├── Stage 1: g_AttenuationFlexible(20×, 20×) → Apply 20× SA/SE growth attenuation
├── Stage 2: Extract damaged sites → data/reversible_SAkilling_post_attenuation.csv
├── Stage 3: g_TreatmentResponse_DualAction → SA-killing on attenuated patients  
└── Stage 4: g_Plot_DualAction → figures/DualAction_Heatmap.png

Attenuation-Only Workflow (Figure S6b-d):
run_AttenuationOnly_supplementary.m
├── 3×3 grid analysis: g_AttenuationFlexible(SA_fold, SE_fold)
│   ├── SA folds: [1×, 10×, 20×] 
│   ├── SE folds: [1×, 10×, 20×]
│   └── Total: 9 combinations × 2 patient types = 18 simulations
├── Weighted combination across patient populations
└── g_Plot_AttenuationOnly → figures/FigureS6_AttenuationHeatmaps.png
```

### Output Files:

### Data Files (Dual-Action Treatment)
- `data/reversible_SAkilling_post_attenuation.csv` - Initial conditions for reversible patients after 20× attenuation
- `data/irreversible_SAkilling_post_attenuation.csv` - Initial conditions for irreversible patients after 20× attenuation  
- `data/reversible_treatment_results_dual_action.csv` - Dual-action treatment simulation results
- `data/irreversible_treatment_results_dual_action.csv` - Dual-action treatment simulation results

### Figure Files
- `figures/DualAction_Heatmap.png` - Main text: Dual-action treatment response heatmap
- `figures/FigureS6_AttenuationHeatmaps.png` - Supplementary: Attenuation-only effectiveness grid
---

## 📊 Data Specifications

### AllVirtualPatientTypes_latest.csv (26 columns)

| Column(s) | Name | Description | Units | Range |
|-----------|------|-------------|-------|-------|
| 1 | Patient ID | Unique parameter set identifier | - | 1 to 10⁶ |
| 2 | Num States | Number of stable steady states | - | 1, 2, or 3 |
| 3 | κ<sub>A</sub> | SA growth rate | day⁻¹ | [9, 27] |
| 4 | A<sub>max</sub> | SA carrying capacity | CFU/cm² | 1.11×10⁹ |
| 5 | γ<sub>AB</sub> | Skin inhibition of SA growth | - | [58.7, 5870] |
| 6 | δ<sub>AE</sub> | SA killing by SE | day⁻¹ | [4.78, 478] |
| 7 | A<sub>th</sub> | SA QS threshold | CFU/cm² | [1.13×10⁷, 1.13×10⁹] |
| 8 | E<sub>pth</sub> | SE density for half-max SA killing | CFU/cm² | [1.13×10⁷, 1.13×10⁹] |
| 9 | γ<sub>AE</sub> | SA QS inhibition by SE | cm²/CFU | [1.30×10⁻⁹, 1.30×10⁻⁷] |
| 10 | κ<sub>E</sub> | SE growth rate | day⁻¹ | [9, 27] |
| 11 | E<sub>max</sub> | SE carrying capacity | CFU/cm² | 1.11×10⁹ |
| 12 | γ<sub>EB</sub> | Skin inhibition of SE growth | - | [55.8, 5580] |
| 13 | δ<sub>EA</sub> | SE killing by SA | day⁻¹ | [4.78, 478] |
| 14 | E<sub>th</sub> | SE QS threshold | CFU/cm² | [1.13×10⁷, 1.13×10⁹] |
| 15 | A<sub>pth</sub> | SA density for half-max SE killing | CFU/cm² | [1.13×10⁷, 1.13×10⁹] |
| 16 | κ<sub>B</sub> | Skin barrier recovery rate | day⁻¹ | [0.00711, 0.711] |
| 17 | δ<sub>B</sub> | Skin desquamation rate | day⁻¹ | [0.00289, 0.289] |
| 18 | δ<sub>BA</sub> | Skin damage by SA | cm²/(CFU·day) | [10⁻¹⁰, 10⁻⁸] |
| 19 | δ<sub>BE</sub> | Skin damage by SE | cm²/(CFU·day) | [10⁻¹², 10⁻⁸] |
| 20 | SA* | SA steady state population | CFU/cm² | ≥ 0 |
| 21 | SE* | SE steady state population | CFU/cm² | ≥ 0 |
| 22 | B* | Barrier function steady state | - | [0, 1] |
| 23-25 | λ₁, λ₂, λ₃ | Stability eigenvalues (Jacobian) | - | Real parts < 0 (locally stable) |
| 26 | Region | Steady state region classification | - | 1-9 |

For further details on parameter descriptions, please refer to Supplementary Table S1 in manuscript. 

### Three Virtual Skin Types (Based on B* across ALL states)

**Asymptomatic**:
- ALL steady states have B* = 1.0
- Undamaged skin that maintains barrier function
- Example: Patient with states [B*=1, B*=1, B*=1]

**Reversible**:
- Has BOTH B* = 1.0 AND B* < 1.0 states
- Can transition between healthy and damaged
- SA-killing can restore barrier function
- Example: Patient with states [B*=1, B*=0.7]

**Irreversible**:
- ALL steady states have B* < 1.0
- AD skin site with persistent barrier damage
- Example: Patient with states [B*=0.8, B*=0.6]

### Region Classification (Column 26)

Based on characteristic SA and SE population densities at steady state (see Supplementary Figure S15):

| Region | SA Population | SE Population | Barrier Status | Description |
|--------|---------------|---------------|----------------|-------------|
| **1** | Absent | Absent | B* = 1 | SA and SE-free skin |
| **2** | Low | Absent | B* = 1 | Low SA colonisation (non-damaging) |
| **3** | Absent | Low | B* = 1 | Low SE colonisation (non-damaging) |
| **4** | Low | Low | B* = 1 | SA-SE coexistence (non-damaging) |
| **5** | Absent | High | B* varies | High SE colonisation (damaging if δ<sub>BE</sub> > 0) |
| **6** | Present | High | B* varies | SA-SE coexistence with SE dominance (damaging if δ<sub>BE</sub> > 0) |
| **7** | High | Absent | B* < 1 | High SA colonisation (damaging) |
| **8** | High | Present | B* < 1 | SA-SE coexistence with SA dominance (damaging) |
| **9** | High | High | B* < 1 | SA-SE coexistence (damaging) |

**Population Thresholds (relative to A<sub>th</sub> and E<sub>th</sub>):**
- "Low": Below quorum sensing threshold
- "High": Above quorum sensing threshold

## 📧 Contact

**Questions? Please either:**
- ✏️ Open an issue on [GitHub](https://github.com/username/SASE-model/issues)
- 📨 Email: j.lee20@imperial.ac.uk

## 📄 License

This work is licensed under a [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License](http://creativecommons.org/licenses/by-nc-nd/4.0/).

**You are free to**:
- Share — copy and redistribute the material

**Under the following terms**:
- Attribution — You must give appropriate credit
- NonCommercial — You may not use the material for commercial purposes
- NoDerivatives — You may not distribute modified versions

## 🔄 Version History

- **v1.1** (2025-10-21): Major refactoring
  - Added comprehensive documentation with complete workflow guide
  - Streamlined workflow to make figures easier to reproduce

- **v1.0** (2024-02-04): Initial release with publication

---

**Ready to get started?** Jump to [Quick Start](#-quick-start) or explore the [Complete Workflow](#-complete-workflow)!