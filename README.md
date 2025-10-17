# SA-SE Model: In Silico Model of AD Lesions with SA-SE Colonisation

This repository contains the code for reproducing the results from: "In Silico Elucidation of Key Drivers of Staphylococcus aureus-Staphylococcus epidermidis-Induced Skin Damage in Atopic Dermatitis Lesions".

## 📄 Publication

**Paper**: Lee, J, Mannan, AA, Miyano, T, Irvine AD, Tanaka RJ. In Silico Elucidation of Key Drivers of Staphylococcus aureus-Staphylococcus epidermidis-Induced Skin Damage in Atopic Dermatitis Lesions. JID Innov 2024;4:100269.

**DOI**: [10.1016/j.xjidi.2024.100269](https://doi.org/10.1016/j.xjidi.2024.100269)

## 📋 Table of Contents

1. [Quick Start](#-quick-start)
2. [Repository Structure](#-repository-structure)
3. [Figure Generation](#-figure-generation)
4. [Complete Workflow](#-complete-workflow)
5. [Data Specifications](#-data-specifications)
6. [Troubleshooting](#-troubleshooting)
7. [Citation](#-citation)
8. [Contact](#-contact)
9. [License](#-license)

## 🚀 Quick Start

### Prerequisites

**Software Requirements:**
- MATLAB R2021b or later
- Statistics and Machine Learning Toolbox (for violin plots)
- Parallel Computing Toolbox

**Hardware Recommendations:**
- **RAM**: 4 GB minimum, 16 GB recommended for full workflow
- **Storage**: ~5 GB for all data files
- **Runtime**: ~10 hours for complete analysis (steady state analysis takes ~7 hours)

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
run run_main.m % generates Figure 3b - d in main text
run run_supplementary.m % generates Figure S2 in supplementary materials
run run_example_site.m % generates Figure S3 in supplementary materials 
```

**Outputs**:

**Treatment strength varied between 0-5 days<sup>-1</sup> and 1-4 days**
- `Fig3_AllSites.png` - Treatment response for all virtual skin sites with a damaged skin state
- `Fig3_Irreversible.png` - Treatment response for irreversible sites
- `Fig3_Reversible.png` - Treatment response for reversible sites

**Treatment strength varied between 0-10 days<sup>-1</sup> and 2-50 days**
- `FigS2_AllSites.png` - Treatment response for all virtual skin sites with a damaged skin state
- `FigS2_Irreversible.png` - Treatment response for irreversible sites
- `FigS2_Reversible.png` - Treatment response for reversible sites

**Treatment response for one example virtual skin site**
- `ExampleSite_PhasePortrait.png` - SA and SE population sizes for one example virtual skin site
- `ExampleSite_TreatmentResponse.png` - Treatment response for one example virtual skin site

**Figures**:
- **Figure 3b-d**: (b) `Fig3_AllSites.png`, (c) `Fig3_Irreversible.png`, and (d) `Fig3_Reversible.png`
- **Supplementary Figure S2**: (a) `FigS2_AllSites.png`, (b) `FigS2_Irreversible.png`, and (c) `FigS2_Reversible.png`
- **Supplementary Figure S3**: (a) `ExampleSite_PhasePortrait.png` and (b) `ExampleSite_TreatmentResponse.png`

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
run run_DualAction.m
run run_Supplementary_a.m
run run_Supplementary_b-d.m
```

**Outputs**:
- `ViolinPlots_all.png` - All virtual skin sites
- `ViolinPlots_damage.png` - Only sites with skin-damaging SE strains (δ<sub>BE</sub> > 0)
- `ViolinPlots_no_damage.png` - Only sites without skin-damaging SE strains (δ<sub>BE</sub> = 0)

**Figures**:
- **Figure 4a**: Highlights 6 key parameters from `ViolinPlots_all.png` (subset of parameters selected by visual inspection)
- **Supplementary Figure S4**: Complete parameter distributions from `ViolinPlots_all.png`
- **Supplementary Figure S5a**: Parameter distributions for damaging SE strains (from `ViolinPlots_damage.png`)
- **Supplementary Figure S5b**: Parameter distributions for non-damaging SE strains (from `ViolinPlots_no_damage.png`)

## 🎨 Summary for Figure Generation

### Main Text Figures

| Figure | Scripts | Folder | Description |
|--------|---------|--------|-------------|
| **Figure 2** | `run_steady_state_plots.m` | Group virtual skin sites | Illustration of three types of virtual skin sites defined by whether the stable skin state converged to undamaged or damaged |
| **Figure 3b-d** | `run_SA_killing_main.m` | Effect of SA-killing | Proportion of all damaged skin sites that recover to an undamaged skin state |
| **Figure 4a** | `run_violin_analysis.m` | Violin plots | Parameter distributions by patient type |
| **Figure 5b-d** | `run_DA_main.m` | Effect of dual-action treatment | Proportion of all damaged skin sites that recover to an undamaged skin state |

### Supplementary Figures

| Figure | Scripts | Folder | Description |
|--------|---------|--------|-------------|
| **Figure S1** | `run_steady_state_plots.m` | Group virtual skin sites | Phase portraits by steady state count |
| **Figure S2** | `run_SA_killing_supp.m` | Effect of SA-killing | Success of SA-killing for longer and stronger treatments |
| **Figure S3** | `run_example_site.m` | Effect of SA-killing | SA-killing applied to one example skin site |
| **Figure S4** | `run_violin_analysis.m` | Violin plots | Distribution of parameters driving asymptomatic, reversible, and irreversible skin sites |
| **Figure S5** | `run_violin_analysis.m` | Violin plots | Distribution of parameters for sites with (a) non-damaging and (b) damaging SE strains |
| **Figure S6a** | `run_...m` | Effect of dual-action treatment | Recovery of damaged skin sites when fixed duration (2 days) and strength (3 days<sup>-1</sup>) of SA-killing is applied, but SA and SE growth attenuations are varied |
| **Figure S6b-d** | `run_DA_supplementary.m` | Effect of dual-action treatment | Percentage of sites that gain a non-damaged state when SA and SE growth attenuation is enhanced by different strengths |


## 📁 Repository Structure

```
SASE-model/
├── Analyse steady states/          # Key workflow: Generate & classify patients
│   ├── run_SteadyStates.m          # Main entry point
│   ├── g_samples.m                 # Generate parameter sets
│   ├── a_SampledParameters.m       # Compute steady states
│   ├── g_VirtualPatients.m         # Assign patient IDs
│   ├── a_PatientGroups.m           # Classify into subtypes based on QS-switches
│   ├── g_classification_csvs.m     # Generate classification CSVs
│   ├── f_computeCase1.m            # Dependency
│   ├── f_computeCase2.m            # Dependency
│   ├── f_computeCase3.m            # Dependency
│   ├── f_computeCase4.m            # Dependency
│   ├── f_defineODEs.m              # Dependency
│   ├── f_SteadyStateCheck.m        # Dependency
│   └── data/
│       ├── asymp.csv               # Asymptomatic skin sites
│       ├── reversible.csv          # Reversible skin sites
│       ├── irreversible.csv        # Irreversible skin sites
│       └── AllVirtualPatientTypes_latest.csv   # Key output
│
├── Group virtual skin sites/       # Visualise virtual skin sites by steady states observed
│   ├── g_PatientTypes_1.m          # Plot virtual skin sites with 1 steady state
│   ├── g_PatientTypes_2.m          # Plot virtual skin sites with 2 steady states
│   ├── g_PatientTypes_3.m          # Plot virtual skin sites with 3 steady states
│   ├── data/                       # AllVirtualPatientTypes_latest.csv grouped into 1, 2, 3 steady states
│   │   ├── One_StableState.csv         
│   │   ├── Two_StableState.csv
│   │   └── Three_StableState.csv
│   └── figures/                    # Outputs from g_PatientTypes_*.m saved here
│       ├── PatientTypes_1_SteadyState.png   
│       ├── PatientTypes_2_SteadyStates.png
│       └── PatientTypes_3_SteadyStates.png
│
├── Effect of SA-killing/           # SA-killing treatment analysis
│
├── SA-killing for example site/    # Example site analysis
│
├── Violin plots/                   # Parameter distribution analysis
│   ├── g_violin_plot.m             # Main plotting function
│   ├── run_violin_analysis.m       # Interactive/batch runner
│   ├── Violin.m                    # Functions to create violin plots
│   ├── violinplot.m                # Functions to create violin plots
│   └── figures/                    # Outputs from run_violin_analysis.m saved here
│       ├── ViolinPlots_all.png    
│       ├── ViolinPlots_SE_damaging.png
│       └── ViolinPlots_SE_nondamaging.png
│
├── Effect of dual-action treatment/ # Dual-action treatment analysis
├── Supplementary data/             # Supplementary materials
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

---

### Stage 1: Generate and Classify Virtual Patients

**Location**: `Analyse steady states/`

#### 1.1 Generate Parameter Sets

```matlab
run g_samples.m
```

- **Output**: `SampledParameters.csv`
- **Description**: Generates 1 million parameter sets sampled from ranges in Table S1
- **Columns**: 17 model parameters (κ_A, γ_AB, δ_AE, A_th, E_pth, γ_AE, κ_E, γ_EB, δ_EA, E_th, A_pth, κ_B, δ_B, δ_BA, δ_BE, S_max, q)

#### 1.2 Analyze Steady States

```matlab
run a_SampledParameters.m
```

- **Input**: `SampledParameters.csv`
- **Output**: `AllSteadyStates.csv`
- **Description**: Computes steady states and stability for each parameter set (~7 hours)
- **Added Columns**: SA*, SE*, B* (steady states), λ₁, λ₂, λ₃ (eigenvalues)

#### 1.3 Create Virtual Patients

```matlab
run g_VirtualPatients.m
```

- **Input**: `AllSteadyStates.csv`
- **Output**: `AllVirtualPatients.csv`
- **Description**: Groups steady states by parameter set ID
- **Added Columns**: Patient ID, Number of stable states

#### 1.4 Classify by Barrier Status

```matlab
run a_PatientGroups.m
```

- **Input**: `AllVirtualPatients.csv`
- **Output**: `data/AllVirtualPatientTypes_latest.csv` (26 columns)
- **Description**: Classifies patients based on B* values across ALL steady states
- **Classification Logic**:
  - **Asymptomatic**: ALL steady states have B* = 1 (healthy barrier)
  - **Irreversible**: ALL steady states have B* < 1 (damaged barrier)
  - **Reversible**: MIX of B* = 1 and B* < 1 states

#### 1.5 Generate Classification CSVs

```matlab
run g_ClassificationFiles.m
```

- **Input**: `data/AllVirtualPatientTypes_latest.csv`
- **Outputs**:
  - `asymp.csv` - Asymptomatic patients
  - `reversible.csv` - Reversible patients
  - `irreversible.csv` - Irreversible patients
- **Description**: Separates patients into three CSV files for violin plot analysis

## Stage 2: Visualise Virtual Skin Sites by Steady State Count

**Location**: `Group virtual skin sites/`

**Purpose**: Generate phase portrait plots of virtual skin sites organised by the number of stable steady states they possess. Creates figures showing SA vs SE populations at steady state, grouped by region combinations and colored by barrier integrity status (red = damaged, yellow = undamaged).

### File Organisation:

### 🚀 Main Runner Script (Single Entry Point)

| Usage | Purpose | Outputs |
|-------|---------|---------|
| **`run_patient_types.m`** | Generate all steady state visualizations | All CSV files and PNG figures |

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
| **`run_main.m`** | Generate Figure 3b-d | Strength 0-5, Duration 1-4 days | `Fig3_AllSites.png`, `Fig3_Reversible.png`, `Fig3_Irreversible.png` |
| **`run_supplementary.m`** | Generate Supplementary Figure S2 | Strength 0-10, Duration 2-50 days | `FigS2_AllSites.png`, `FigS2_Reversible.png`, `FigS2_Irreversible.png` |
| **`run_supplementary_example_site.m`** | Generate Supplementary Figure S3 | Single patient analysis | `FigS3_PhasePortrait.png`, `FigS3_TreatmentResponse.png` |

### 🔧 Core Analysis Functions (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`g_ExtractInitialConditions.m`** | Extract worst-case initial conditions for treatment simulations (see Materials and Methods in paper) | `run_main.m`, `run_supplementary.m` |
| **`g_TreatmentResponse.m`** | Run SA-killing treatment grid simulations<br/>**Input**: `data/reversible_SAkilling.csv`<br/>**Output**: `data/reversible_treatment_results_[suffix].csv`<br/>*Suffix: 'main' or 'supp' to prevent overwriting* | `run_main.m`, `run_supplementary.m` |

### 📊 Visualisation Functions (Called Automatically)

| Function | Purpose | Used By |
|----------|---------|---------|
| **`g_Plot_Main.m`** | Generate main text heatmaps with contour lines (Figure 3b-d) | `run_main.m` |
| **`g_Plot_Supplementary.m`** | Generate supplementary heatmaps with exact values (Supplementary Figure S2) | `run_supplementary.m` |
| **`g_VisualiseExampleSites.m`** | Generate phase portrait plot (Supplementary Figure S3a) | `run_supplementary_example_site.m` |
| **`g_ExampleSiteAnalysis.m`** | Generate treatment response plot for a single patient (Supplementary Figure S3b) | `run_supplementary_example_site.m` |

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
run_main.m
├── g_ExtractInitialConditions.m → data/reversible_SAkilling.csv, data/irreversible_SAkilling.csv
├── g_TreatmentResponse.m → data/reversible_treatment_results.csv
└── g_Plot_Main.m → figures/Fig3_AllSites.png, Fig3_Reversible.png, Fig3_Irreversible.png

Supplementary Workflow (Figure S2):
run_supplementary.m  
├── [Same extraction and treatment steps with different parameters]
└── g_Plot_Supplementary.m → figures/FigS2_AllSites.png, FigS2_Reversible.png, FigS2_Irreversible.png

Example Site Workflow (Figure S3):
run_supplementary_example_site.m
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
- `figures/Fig3_AllSites.png` - Main text: Combined treatment response heatmap
- `figures/Fig3_Reversible.png` - Main text: Reversible patients treatment response
- `figures/Fig3_Irreversible.png` - Main text: Irreversible patients treatment response
- `figures/FigS2_AllSites.png` - Supplementary: Extended parameter range heatmap (combined)
- `figures/FigS2_Reversible.png` - Supplementary: Extended parameter range (reversible)
- `figures/FigS2_Irreversible.png` - Supplementary: Extended parameter range (irreversible)
- `figures/FigS3_PhasePortrait.png` - Supplementary: Single patient phase portrait
- `figures/FigS3_TreatmentResponse.png` - Supplementary: Single patient treatment response

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
| **`violinplot.m`** | User-friendly wrapper for creating violin plots with customization options. Downloaded from Holger Hoffmann (2025). Violin Plot (https://www.mathworks.com/matlabcentral/fileexchange/45134-violin-plot), MATLAB Central File Exchange. Retrieved October 17, 2025. | `g_violin_plot.m` |
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

---

### Stage 5: Dual-action treatment strategy

**Location**: `Effect of SA-killing/` and `Effect of dual-action treatment/`

[To be documented]

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

For further details on parameter descriptions, please refer to Supplementary Table S1. 

### Classification Rules

#### Patient Type (Based on B* across ALL states)

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

#### Region Classification (Column 26)

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


**Key Characteristics:**
- **Regions 1-4**: Low bacterial loads, healthy barrier (B* = 1)
- **Region 5**: High SE only; barrier status depends on whether SE strain is skin damaging (δ<sub>BE</sub> > 0)
- **Region 6**: SA-SE coexistence; barrier status depends on whether SE strain is skin damaging (δ<sub>BE</sub> > 0)
- **Region 7**: High SA only; always damaging
- **Regions 8 & 9**: Merged in visualisations as both represent high SA-SE co-colonisation with damaged barrier


**Population Thresholds (relative to A<sub>th</sub> and E<sub>th</sub>):**
- "Low": Below quorum sensing threshold
- "High": Above quorum sensing threshold

---

## 🐛 Troubleshooting

### Common Issues

#### "File not found" errors

**Problem**: Script can't find data files

**Solutions**:
- Ensure you're running scripts from their respective folders
- Check that `AllVirtualPatientTypes_latest.csv` exists in `Analyse steady states/data/`
- Verify relative paths in scripts match your folder structure

#### Out of memory errors

**Problem**: Large datasets exceed available RAM

**Solutions**:
- Close other applications
- Process in smaller batches (modify `g_samples.m` to generate fewer parameter sets)
- Use a machine with at least 16 GB RAM

#### Statistics Toolbox not available

**Problem**: `ksdensity` requires Statistics and Machine Learning Toolbox

**Solutions**:
- **Automatic**: Scripts automatically use box plots instead (no action needed)
- **Install toolbox**: See [MATLAB Add-On Explorer](https://www.mathworks.com/help/matlab/matlab_env/get-add-ons.html)
- Box plots show the same information as violin plots

#### Plots look different from paper

**Problem**: Generated figures don't match publication

**Solutions**:
- Verify you're using correct CSV files:
  - Violin plots: Use `asymp.csv`, `reversible.csv`, `irreversible.csv`
  - NOT intermediate files like `One_StableState.csv`
- Check MATLAB version (R2021b or later recommended)
- Ensure random seed is set if comparing exact parameter sets

#### Script runs but produces no output

**Problem**: Script completes but no files generated

**Solutions**:
- Check current working directory: `pwd`
- Look for output files in script's folder
- Check MATLAB command window for error messages
- Verify input files exist before running

### Performance Tips

- **Parallel processing**: Some scripts support `parfor` - ensure Parallel Computing Toolbox is available
- **Disk I/O**: Use SSD for faster file operations
- **Memory**: Monitor memory usage with `memory` command
- **Batch mode**: Use `matlab -batch` for unattended runs

---

## 📜 Citation

If you use this code in your research, please cite:

```bibtex
@article{lee2024silico,
  title={In Silico Elucidation of Key Drivers of Staphylococcus aureus-Staphylococcus epidermidis-Induced Skin Damage in Atopic Dermatitis Lesions},
  author={Lee, Jamie and Mannan, Abdul Ahad and Miyano, Tatsuo and Irvine, Alan D and Tanaka, Reiko J},
  journal={JID Innovations},
  volume={4},
  pages={100269},
  year={2024},
  publisher={Elsevier},
  doi={10.1016/j.xjidi.2024.100269}
}
```

---

## 📧 Contact

**Questions or Issues?**
- Open an issue on [GitHub](https://github.com/username/SASE-model/issues)
- Email: j.lee20@imperial.ac.uk

**Author**: Jamie Lee  
**Affiliation**: Department of Bioengineering, Imperial College London  
**Lab**: [Tanaka Lab Website](https://www.imperial.ac.uk/tanaka-rj-lab)

---

## 📄 License

This work is licensed under a [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License](http://creativecommons.org/licenses/by-nc-nd/4.0/).

**You are free to**:
- Share — copy and redistribute the material

**Under the following terms**:
- Attribution — You must give appropriate credit
- NonCommercial — You may not use the material for commercial purposes
- NoDerivatives — You may not distribute modified versions

---

## 🔄 Version History

- **v1.1** (2025-10-XX): Major refactoring
  - Added streamlined violin plot scripts with automatic Statistics Toolbox fallback
  - Added automatic CSV classification generation (`g_ClassificationFiles.m`)
  - Improved steady state visualization with dynamic region detection
  - Added comprehensive documentation with complete workflow guide
  - Batch mode support for all visualization scripts
  - Fixed underscores in plot titles (no more unwanted subscripts!)

- **v1.0** (2024-XX-XX): Initial release with publication

---

**Ready to get started?** Jump to [Quick Start](#-quick-start) or explore the [Complete Workflow](#-complete-workflow)!