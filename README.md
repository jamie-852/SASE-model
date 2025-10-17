# SA-SE Model: In Silico Model of AD Lesions with SA-SE Colonisation

This repository contains the code for reproducing the results from: "In Silico Elucidation of Key Drivers of Staphylococcus aureus-Staphylococcus epidermidis-Induced Skin Damage in Atopic Dermatitis Lesions".

## 📄 Publication

**Paper**: Lee, J, Mannan, AA, Miyano, T, Irvine AD, Tanaka RJ. In Silico Elucidation of Key Drivers of Staphylococcus aureus-Staphylococcus epidermidis-Induced Skin Damage in Atopic Dermatitis Lesions. JID Innov 2024;4:100269.

**DOI**: [10.1016/j.xjidi.2024.100269](https://doi.org/10.1016/j.xjidi.2024.100269)

---

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

---

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
- Each site includes 17 sampled parameters (where A_max and E_max are fixed) and 9 computed values (steady states, eigenvalues, region classification)

**More info**: See [Data Specifications](#📊-data-specifications) for complete 26-column description and region classification rules.

---

#### Step 2: Visualise Steady State Subtypes → Figure 2, Supplementary Figure S1
```matlab
% Navigate to sub-type visualisation folder
cd '../Group virtual skin sites'

% Generate steady state subtype plots
run run_patient_types.m
```

**Outputs**: Phase portraits showing SA (x-axis) vs SE (y-axis) populations at steady state, colored by barrier integrity (yellow for B* = 1, red for B* < 1)

- `PatientTypes_1_SteadyState.png` - Sites with 1 steady state (8 subplots)
- `PatientTypes_2_SteadyStates.png` - Sites with 2 steady states (21 subplots)
- `PatientTypes_3_SteadyStates.png` - Sites with 3 steady states (19 subplots)

**Figures**: 
- **Supplementary Figure S1**: Uses subplots from the three generated files above (subplots were manually rearranged for publication)
- **Figure 2**: Characterisation of three main skin types (Asymptomatic, Reversible, Irreversible) based on this analysis

---

#### Step 3: Treatment Simulations → Figure 3, Supp. Figures S2-S3
```matlab
% Navigate to SA-killing treatment folder
cd '../Effect of SA-killing'

% Explore effect of SA-killing treatment
run run_main.m % generates Figure 3b - d in main text
run run_supplementary.m % generates Figure S2 in supplementary materials
run run_example_site.m % generates Figure S3 in supplementary materials 
```

**Outputs**:

**Treatment strength varied between X-Y days^[-1] and X-Y days**
- `Fig3_AllSites.png` - Treatment response for all virtual skin sites with damaged skin state
- `Fig3_Irreversible.png` - Treatment response for irreversible sites
- `Fig3_Reversible.png` - Treatment response for reversible sites

**Treatment strength varied between X-Y days and X-Y days**
- `FigS2_AllSites.png` - Treatment response for all virtual skin sites with damaged skin state
- `FigS2_Irreversible.png` - Treatment response for irreversible sites
- `FigS2_Reversible.png` - Treatment response for reversible sites

**Treatment response for one example virtual skin site**
- `ExampleSite_PhasePortrait.png` - SA and SE population sizes for one example virtual skin site
- `ExampleSite_TreatmentResponse.png` - Treatment response for one example virtual skin site

**Figures**:
- **Figure 3b - d**: `Fig3_AllSites.png`, `Fig3_Irreversible.png`, and `Fig3_Reversible.png`
- **Supplementary Figure S2**: `FigS2_AllSites.png`, `FigS2_Irreversible.png`, and `FigS2_Reversible.png`
- **Supplementary Figure S3**: `ExampleSite_PhasePortrait.png` and `ExampleSite_TreatmentResponse.png`

---

#### Step 4: Parameter Distribution Analysis → Figure 4a, Supplementary Figures S4-S5
```matlab
% Navigate to violin plots folder
cd '../Violin plots'

% Generate all parameter distribution plots
run run_violin_analysis('generate_all', true)
```

**Outputs**: Violin plots comparing 15 parameter distributions (A<sub>max</sub> and E<sub>max</sub> are fixed at 1.11×10⁹) across patient types (Asymptomatic, Reversible, Irreversible)

- `ViolinPlots_all.png` - All virtual skin sites
- `ViolinPlots_damage.png` - Only sites with skin-damaging SE strains (δ<sub>BE</sub> > 0)
- `ViolinPlots_no_damage.png` - Only sites without skin-damaging SE strains (δ<sub>BE</sub> = 0)

**Figures**: 
- **Figure 4a**: Highlights 6 key parameters from `ViolinPlots_all.png` (subset of parameters selected by visual inspection)
- **Supplementary Figure S4**: Complete parameter distributions from `ViolinPlots_all.png`
- **Supplementary Figure S5a**: Parameter distributions for damaging SE strains (from `ViolinPlots_damage.png`)
- **Supplementary Figure S5b**: Parameter distributions for non-damaging SE strains (from `ViolinPlots_no_damage.png`)

---

#### Step 5: Proposed Treatment Strategy → Figure 5, Supp. Figure S6
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

---

## 🎨 Figure Generation

### Main Text Figures

| Figure | Scripts | Folder | Description |
|--------|---------|--------|-------------|
| **Figure 2** | `run_steady_state_plots.m` | Group virtual skin sites | Phase portraits by steady state count |
| **Figure 3** | `run_violin_analysis.m` | Violin plots | Parameter distributions by patient type |
| **Figure 4** | [TBD] | Effect of SA-killing treatment | Treatment response analysis |
| **Figure 5** | [TBD] | Effect of dual-action treatment | Treatment response analysis |

### Supplementary Figures

| Figure | Scripts | Folder | Description |
|--------|---------|--------|-------------|
| **Figure S1** | `run_steady_state_plots.m` | Group virtual skin sites | All 3-state combinations |
| **Figure S2-S10** | [TBD] | Various | Additional analyses |


---

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

---

## 🔄 Complete Workflow

### Overview

The analysis pipeline consists of four main stages:

```
[1] Generate & Classify → [2] Visualize Steady States → [3] Analyze Parameters → [4] Simulate Treatments
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

---

### Stage 2: Visualize by Number of Steady States

**Location**: `Group virtual skin sites/`

**Purpose**: Visualize virtual skin sites organized by how many steady states they have (1, 2, or 3), regardless of barrier status.

#### Interactive Use

```matlab
cd 'Group virtual skin sites'

% Run all three at once
run run_steady_state_plots('all')

% Or individually
run run_steady_state_plots(1)  % 1-state patients only
run run_steady_state_plots(2)  % 2-state patients only
run run_steady_state_plots(3)  % 3-state patients only
```

#### Batch Mode

```bash
# From command line
matlab -batch "cd('Group virtual skin sites'); run_steady_state_plots('all')"
```

#### Outputs

- `PatientTypes_1_SteadyState.png` - 8 subplots (different single regions)
- `PatientTypes_2_SteadyStates.png` - 21 subplots (region pairs)
- `PatientTypes_3_SteadyStates.png` - Variable subplots (ALL region triplets found in data)

**Key Features**:
- Plots show SA vs SE phase portraits (log scale)
- Colors: Green (B* = 1), Red (B* < 1)
- Automatically detects all unique region combinations
- Dynamic subplot layout based on data

---

### Stage 3: Apply SA-killing treatment

**Location**: `Effect of SA-killing/`

**Purpose**: Analyse SA-killing treatment effectiveness on virtual patients with damaged skin barrier. Focuses specifically on reversible and irreversible skin sites.

#### 📁 File organisation:

#### 🚀 Main runner scripts (Entry Points)
1. run_main.m
  - Purpose: Generate Figure 3b-d (main text)
  - Parameters: Strength 0-5, Duration 1-4 days
  - Outputs: Fig3_AllSites.png, Fig3_Reversible.png, Fig3_Irreversible.png
2. run_supplementary.m
  - Purpose: Generate Supplementary Figure S2 (supplementary)
  - Parameters: Strength 0-10, Duration 2-50 days
  - Outputs: FigS2_AllSites.png, FigS2_Reversible.png, FigS2_Irreversible.png
3. run_supplementary_example_site.m
  - Purpose: Generate Supplementary Figure S3 (supplementary)
  - Parameters: ... (!!!)
  - Outputs: FigS3_PhasePortrait.png, FigS3_TreatmentResponse.png

#### 🔧 Core analysis functions (called automatically by main scripts)
4. g_ExtractInitialConditions.m
  - Purpose: Extract worst-case initial conditions for treatment simulations (see Materials and Methods in paper)
  - Used by: run_main.m, run_supplementary.m
5. g_TreatmentResponse.m
  - Purpose: Run SA-killing treatment grid simulations
  - Input: data/reversible_SAkilling.csv
  - Output: data/reversible_treatment_results.csv

#### 📊 Visualisation functions (called automatically by main scripts)
6. g_Plot_Main.m
  - Purpose: Generate main text heatmaps with contour lines (Figure 3b-d)
  - Used by: run_main.m
7. g_Plot_Supplementary.m
  - Purpose: Generate supplementary heatmaps with exact values
  - Used by: run_supplementary.m
8. g_VisualiseExampleSites.m
  - Purpose: Generate phase portrait plot (Supplementary Figure S3a)
  - Used by: run_supplementary_example_site.m
9. g_ExampleSiteAnalysis.m
  - Purpose: Generate treatment response plot for a single patient (Supplementary Figure S3b)
  - Used by: run_supplementary_example_site.m

#### ⚙️ Mathematical functions (called automatically by main scripts)
10. f_defineODEs.m - ODEs defining mathematical model
11. f_defineODEs_SAkilling.m - ODEs with SA-killing term
12. f_EventHealthy.m - event detection for when a healthy state (B = 1) is reached


```matlab
cd 'Group virtual skin sites'

% Run all three at once
run run_steady_state_plots('all')

% Or individually
run run_steady_state_plots(1)  % 1-state patients only
run run_steady_state_plots(2)  % 2-state patients only
run run_steady_state_plots(3)  % 3-state patients only
```

#### Batch Mode

```bash
# From command line
matlab -batch "cd('Group virtual skin sites'); run_steady_state_plots('all')"
```

#### Outputs

- `PatientTypes_1_SteadyState.png` - 8 subplots (different single regions)
- `PatientTypes_2_SteadyStates.png` - 21 subplots (region pairs)
- `PatientTypes_3_SteadyStates.png` - Variable subplots (ALL region triplets found in data)

**Key Features**:
- Plots show SA vs SE phase portraits (log scale)
- Colors: Green (B* = 1), Red (B* < 1)
- Automatically detects all unique region combinations
- Dynamic subplot layout based on data

---

### Stage 4: Analyze Parameter Distributions

**Location**: `Violin plots/`

**Purpose**: Compare parameter distributions across asymptomatic, reversible, and irreversible patient types.

#### Interactive Use

```matlab
cd 'Violin plots'

% Interactive mode (prompts for choices)
run run_violin_analysis()

% Direct specification
run run_violin_analysis('all', false)        % All patients
run run_violin_analysis('damage', false)     % Only with damage
run run_violin_analysis('no_damage', false)  % Only without damage
run run_violin_analysis('generate_all')      % All three versions
```

#### Batch Mode

```bash
# From command line - generate all three versions
matlab -batch "cd('Violin plots'); run_violin_analysis('generate_all', true)"
```

#### Outputs

**With Statistics Toolbox**:
- `ViolinPlots_all.png` - All patients (violin plots)
- `ViolinPlots_damage.png` - Only with skin-damaging SE (δ_BE > 0)
- `ViolinPlots_no_damage.png` - Only without skin-damaging SE (δ_BE = 0)

**Without Statistics Toolbox** (automatic fallback):
- `ParameterPlots_all.png` - All patients (box plots)
- `ParameterPlots_damage.png` - Only with damage
- `ParameterPlots_no_damage.png` - Only without damage

**Parameters Shown**: 15 model parameters compared across Asymptomatic (orange), Reversible (gray), and Irreversible (red) patient types.

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