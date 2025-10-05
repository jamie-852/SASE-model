# SA-SE Model - Complete Reproduction Guide

This guide provides step-by-step instructions for reproducing all results from the paper "In silico model of AD lesions with SA-SE colonisation".

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Complete Workflow](#complete-workflow)
4. [Data Specifications](#data-specifications)
5. [Figure Generation Map](#figure-generation-map)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Software Requirements
- MATLAB R20XXa or later
- Required toolboxes: [List any specific toolboxes needed]

### Initial Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/jamie-852/SASE-model.git
   cd SASE-model
   ```

2. Verify all folders are present:
   - `1. Analyse steady states/`
   - `2. Effect of SA-killing/`
   - `3. Effect of dual-action treatment/`
   - `4. Group virtual skin sites/`
   - `5. SA-killing for example site/`
   - `6. Supplementary data/`
   - `7. Violin plots/`
   - `8. Info/`

---

## Quick Start

To reproduce all main results, run the following in order:

```matlab
% Step 1: Generate base data (Folder 1)
cd '1. Analyse steady states'
run g_samples.m
run a_SampledParameters.m
run g_VirtualPatients.m
run a_PatientGroups.m

% Step 2: Generate classification files (Folder 1)
run g_ClassificationFiles.m  % Generates asymp.csv, rev_SAkilling.csv, irrev_SAkilling.csv

% Step 3: Generate violin plots (Folder 7)
cd '../7. Violin plots'
run g_ViolinPlots.m

% Additional analyses available in folders 2-6
```

---

## Complete Workflow

### Script Naming Convention

Throughout the repository:
- **`f_*.m`** - Function definitions (called by other scripts)
- **`g_*.m`** - Generate/create data files
- **`a_*.m`** - Analyze existing data

### Folder 1: Analyse Steady States (CORE WORKFLOW)

**Purpose**: Generate all virtual patient data and classify steady states

**Execution order**:

1. **`g_samples.m`**
   - **Input**: None (uses parameter ranges from Table S1)
   - **Output**: `SampledParameters.mat` or `.csv` (1 million parameter sets)
   - **Columns**: 17 columns representing model parameters (see Data Specifications)
   - **Runtime**: ~X minutes

2. **`a_SampledParameters.m`**
   - **Input**: Output from `g_samples.m`
   - **Output**: `AllSteadyStates.mat` or `.csv`
   - **Columns**: 
     - Cols 1-17: Model parameters
     - Cols 18-20: Steady states (A*, E*, B*)
     - Cols 21-23: Eigenvalues for stability
   - **Runtime**: ~X minutes

3. **`g_VirtualPatients.m`**
   - **Input**: `AllSteadyStates` file
   - **Output**: `AllVirtualPatients.mat` or `.csv`
   - **Columns**:
     - Col 1: Virtual skin site ID (unique parameter set identifier)
     - Col 2: Number of stable states present
     - Cols 3+: [Inherited from previous file]
   - **Runtime**: ~X minutes

4. **`a_PatientGroups.m`**
   - **Input**: `AllVirtualPatients` file
   - **Output**: `AllVirtualPatientTypes.mat` or `.csv` (26 columns)
   - **Columns**:
     - Cols 1-17: Model parameters
     - Cols 18-20: Steady states (A*, E*, B*)
     - Cols 21-23: Eigenvalues
     - Cols 24: Patient type classification (0=Asymp, 1=Rev, 2=Irrev)
     - Col 25: Region classification (1-9, see Supplementary Note 3)
     - Col 26: [Additional classification if applicable]
   - **Runtime**: ~X minutes

5. **`g_ClassificationFiles.m`** (NEW - generates violin plot inputs)
   - **Input**: `AllVirtualPatientTypes` file
   - **Output**: Three CSV files:
     - `asymp.csv` - Virtual patients with only B*=1 states (asymptomatic)
     - `rev_SAkilling.csv` - Patients with both B*=1 AND B*<1 states (reversible)
     - `irrev_SAkilling.csv` - Patients with only B*<1 states (irreversible)
   - **Runtime**: ~X minutes

### Folder 7: Violin Plots

**Purpose**: Generate violin plots for Figure X

**Execution order**:

1. **`g_ViolinPlots.m`**
   - **Input**: Three classification files from Folder 1:
     - `asymp.csv`
     - `rev_SAkilling.csv`
     - `irrev_SAkilling.csv`
   - **Output**: Violin plot figures
   - **Generates**: [List specific figures]

**Note**: The intermediate files `One_StableState.csv`, `Two_StableStates.csv`, and `ThreeOrMore_StableStates.csv` are NOT used as direct inputs for violin plots. The three classification files above are the correct inputs.

### Folder 2: Effect of SA-killing

**Purpose**: [Describe purpose]

**Execution order**:
[To be documented]

### Folder 3: Effect of Dual-Action Treatment

**Purpose**: [Describe purpose]

**Execution order**:
[To be documented]

### Folder 4: Group Virtual Skin Sites

**Purpose**: [Describe purpose]

**Execution order**:
[To be documented]

### Folder 5: SA-killing for Example Site

**Purpose**: [Describe purpose]

**Execution order**:
[To be documented]

### Folder 6: Supplementary Data

**Purpose**: [Describe purpose]

**Execution order**:
[To be documented]

---

## Data Specifications

### AllVirtualPatientTypes.csv (26 columns)

| Column(s) | Parameter | Description | Source |
|-----------|-----------|-------------|--------|
| 1-17 | Model parameters | See Table S1 in Supplementary Materials | g_samples.m |
| 1 | κ_SA | [Description] | - |
| 2 | κ_SE | [Description] | - |
| 3 | δ_A | [Description] | - |
| 4 | δ_E | [Description] | - |
| 5 | δ_B | [Description] | - |
| 6-17 | [Other params] | [Descriptions] | - |
| 18 | A* | Steady state for SA population | a_SampledParameters.m |
| 19 | E* | Steady state for SE population | a_SampledParameters.m |
| 20 | B* | Steady state for barrier function | a_SampledParameters.m |
| 21-23 | λ₁, λ₂, λ₃ | Eigenvalues for stability analysis | a_SampledParameters.m |
| 24 | Type | Patient classification (0/1/2) | a_PatientGroups.m |
| 25 | Region | Region classification (1-9) | a_PatientGroups.m |
| 26 | [TBD] | [Additional classification] | a_PatientGroups.m |

### Classification Rules

#### Patient Type Categories (Column 24)

**0 - Asymptomatic**:
- Virtual patient has ONLY stable states where B* = 1.0 (healthy barrier)
- No states with compromised barrier (B* < 1.0)
- Represents healthy skin that maintains barrier function

**1 - Reversible SA-killing**:
- Virtual patient has BOTH:
  - At least one stable state with B* = 1.0 (healthy)
  - At least one stable state with B* < 1.0 (damaged)
- Represents patients who can transition between healthy and damaged states
- Intervention (SA-killing) can restore barrier function

**2 - Irreversible SA-killing**:
- Virtual patient has ONLY stable states where B* < 1.0 (damaged barrier)
- No healthy stable states available
- Represents chronic AD with persistent barrier dysfunction

**Precision threshold**: B* = 1.0 is checked with floating-point precision of [X decimal places]

#### Region Classifications (Column 25)

Based on characteristic population densities of SA and SE (see Supplementary Note 3):

| Region | SA Level | SE Level | Barrier State | Description |
|--------|----------|----------|---------------|-------------|
| 1 | Low | Low | Healthy | [Description] |
| 2 | Low | High | [State] | [Description] |
| 3 | High | Low | [State] | [Description] |
| 4 | High | High | [State] | [Description] |
| 5 | [Level] | [Level] | [State] | [Description] |
| 6 | [Level] | [Level] | [State] | [Description] |
| 7 | [Level] | [Level] | [State] | [Description] |
| 8 | [Level] | [Level] | [State] | [Description] |
| 9 | [Level] | [Level] | [State] | [Description] |

**Special cases**:
- **Regions 8/9 (merged)**: [Explain how to handle]
- **Same-region multiple states** (e.g., 5-5): When a patient has two stable states both in region 5, classify as [rule]
- **Three or more stable states**: [Explain classification logic]

---

## Figure Generation Map

| Figure | Folder | Scripts | Input Files | Output |
|--------|--------|---------|-------------|--------|
| **Main Text** |
| Fig. 1 | [Folder #] | [scripts] | [inputs] | [description] |
| Fig. 2 | [Folder #] | [scripts] | [inputs] | [description] |
| Fig. 3 | 7. Violin plots | g_ViolinPlots.m | asymp.csv, rev_SAkilling.csv, irrev_SAkilling.csv | Violin plot comparison |
| Fig. 4 | [Folder #] | [scripts] | [inputs] | [description] |
| **Supplementary** |
| Fig. S1 | [Folder #] | [scripts] | [inputs] | [description] |
| Fig. S2 | [Folder #] | [scripts] | [inputs] | [description] |
| Fig. S3 | [Folder #] | [scripts] | [inputs] | [description] |

---

## Troubleshooting

### Common Issues

**Issue**: "File not found" error when running scripts
- **Solution**: Ensure you're in the correct folder. Each script should be run from its respective folder, or update file paths in the scripts.

**Issue**: Out of memory errors
- **Solution**: The 1 million parameter sets require significant memory. Consider:
  - Running on a machine with at least [X] GB RAM
  - Processing in batches (modify g_samples.m to generate smaller batches)

**Issue**: Violin plots look different from paper
- **Solution**: Ensure you're using the three classification files (asymp.csv, rev_SAkilling.csv, irrev_SAkilling.csv) NOT the intermediate files (One_StableState.csv, etc.)

**Issue**: Region classifications don't match expectations
- **Solution**: Check the region definition thresholds in a_PatientGroups.m against Supplementary Note 3

### Performance Notes

Total runtime for complete workflow: ~[X] hours on [specifications]

Disk space required: ~[X] GB for all intermediate files

---

## Contact

If you encounter issues not covered in this guide, please open an issue on GitHub or contact [your email].

## Citation

If you use this code, please cite:
```
[Full citation]
```

---

## Changelog

- v1.1 (2025-XX-XX): Added REPRODUCTION_GUIDE.md, classification file generation script
- v1.0 (20XX-XX-XX): Initial release