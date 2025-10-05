# SA-SE Model: In Silico Model of AD Lesions with SA-SE Colonisation

This repository contains the code for reproducing the results from: "In Silico Elucidation of Key Drivers of  Staphyloccocus aureus-Staphyloccocus epidermidis-Induced Skin Damage in Atopic Dermatitis Lesions".

## 📄 Publication

**Paper**: Lee, J, Mannan, AA, Miyano, T, Irvine AD, Tanaka RJ. In Silico Elucidation of Key Drivers of  Staphyloccocus aureus-Staphyloccocus epidermidis-Induced Skin Damage in Atopic Dermatitis Lesions. JID Innov 2024;4:100269.
**Journal**: JID Innovations
**DOI**: doi:10.1016/j.xjidi.2024.100269

## 🚀 Quick Start

**For detailed reproduction instructions, see [REPRODUCTION_GUIDE.md](REPRODUCTION_GUIDE.md)**

### Minimal Example

```matlab
% Navigate to the core analysis folder
cd 'Analyse steady states'

% Run the complete workflow
run g_samples.m              % Generate parameter sets
run a_SampledParameters.m    % Analyze steady states
run g_VirtualPatients.m      % Create virtual patients
run a_PatientGroups.m        % Classify patients
run g_ClassificationFiles.m  % Generate classification files

% Generate violin plots
cd '../Violin plots'
run g_ViolinPlots.m
```

## 📁 Repository Structure

```
SASE-model/
├── 1. Analyse steady states/    # Core workflow: Generate & classify virtual patients
├── 2. Effect of SA-killing/     # Analysis of SA-killing interventions
├── 3. Effect of dual-action treatment/  # Dual-action treatment analysis
├── 4. Group virtual skin sites/ # Virtual skin site grouping
├── 5. SA-killing for example site/  # Example site analysis
├── 6. Supplementary data/       # Supplementary materials
├── 7. Violin plots/             # Violin plot generation
├── 8. Info/                     # Additional information
├── README.md                    # This file
└── REPRODUCTION_GUIDE.md        # Detailed reproduction instructions
```

## 📊 Workflow Overview

### Script Naming Convention

- **`f_*.m`** - Function definitions (helper functions)
- **`g_*.m`** - Generate/create data files
- **`a_*.m`** - Analyze existing data

### Core Workflow (Folder 1)

```
g_samples.m
    ↓ (generates SampledParameters)
a_SampledParameters.m
    ↓ (generates AllSteadyStates)
g_VirtualPatients.m
    ↓ (generates AllVirtualPatients)
a_PatientGroups.m
    ↓ (generates AllVirtualPatientTypes)
g_ClassificationFiles.m
    ↓ (generates asymp.csv, rev_SAkilling.csv, irrev_SAkilling.csv)
[Use in Folder 7 for violin plots]
```

## 📖 Documentation

- **[REPRODUCTION_GUIDE.md](REPRODUCTION_GUIDE.md)** - Instructions for reproducing results from paper
- **[DATA_DICTIONARY.md](DATA_DICTIONARY.md)** - Detailed column specifications
- **Supplementary Materials** - See published paper for theoretical background

## 🔬 Key Features

- Generation of 1 million virtual patient parameter sets
- Steady-state analysis of SA-SE-barrier dynamics
- Classification of patients into asymptomatic, reversible, and irreversible categories
- Analysis of SA-killing and dual-action treatment effects

## 💻 Requirements

- **Software**: MATLAB R2021b or later
- **Toolboxes**: [List required toolboxes]
- **RAM**: At least [X] GB recommended
- **Disk Space**: ~[X] GB for all data files
- **Runtime**: ~[X] hours for complete workflow

## 📝 Data Files

### Main Outputs

| File | Description | Dimensions | Source Script |
|------|-------------|------------|---------------|
| `AllVirtualPatientTypes.csv` | Complete virtual patient dataset | N × 26 | `a_PatientGroups.m` |
| `asymp.csv` | Asymptomatic patients (B*=1 only) | N₀ × 26 | `g_ClassificationFiles.m` |
| `rev_SAkilling.csv` | Reversible patients (B*=1 and B*<1) | N₁ × 26 | `g_ClassificationFiles.m` |
| `irrev_SAkilling.csv` | Irreversible patients (B*<1 only) | N₂ × 26 | `g_ClassificationFiles.m` |

### Column Structure (26 columns)

- **Columns 1-17**: Model parameters (see Table S1 in paper)
- **Columns 18-20**: Steady states (A*, E*, B*)
- **Columns 21-23**: Eigenvalues for stability
- **Columns 24-26**: Classification labels

## 🎨 Figure Generation

| Figure | Folder | Key Scripts |
|--------|--------|-------------|
| Figure 1 | [Folder #] | [Scripts] |
| Figure 2 | [Folder #] | [Scripts] |
| Figure 3 (Violin plots) | Folder 7 | `g_ViolinPlots.m` |
| Figure S1-S10 | [Various] | [See REPRODUCTION_GUIDE.md] |

See [REPRODUCTION_GUIDE.md](REPRODUCTION_GUIDE.md) for complete figure-to-script mapping.

## 🐛 Troubleshooting

### Common Issues

1. **"File not found" errors**: Ensure you're running scripts from their respective folders
2. **Out of memory**: Requires ~[X] GB RAM; consider processing in batches
3. **Different results**: Verify MATLAB version and random seed settings

See [REPRODUCTION_GUIDE.md](REPRODUCTION_GUIDE.md) for more troubleshooting tips.

## 📧 Contact

**Questions about reproduction?** Please open an issue on GitHub

**Author**: Jamie Lee
**Email**: j.lee20@imperial.ac.uk
**Institution**: Department of Bioengineering, Imperial College London

## 📜 License

This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.

## 🔄 Changelog

- **v1.1** (2025-XX-XX): Added REPRODUCTION_GUIDE.md, classification file generator
- **v1.0** (20XX-XX-XX): Initial release with paper

---

**Need help?** Start with [REPRODUCTION_GUIDE.md](REPRODUCTION_GUIDE.md) or open an issue!