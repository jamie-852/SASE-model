# Frequently Asked Questions (FAQ)

This document answers common questions about reproducing results from the SASE model paper.

## Table of Contents
1. [Workflow Questions](#workflow-questions)
2. [Data File Questions](#data-file-questions)
3. [Classification Questions](#classification-questions)
4. [Technical Issues](#technical-issues)
5. [Results Interpretation](#results-interpretation)

---

## Workflow Questions

### Q1: What is the correct execution order for the scripts?

**A:** The core workflow in Folder 1 must be run first, in this exact order:

1. `g_samples.m` → generates parameter sets
2. `a_SampledParameters.m` → analyzes steady states
3. `g_VirtualPatients.m` → creates virtual patient IDs
4. `a_PatientGroups.m` → assigns classifications
5. `g_ClassificationFiles.m` → generates violin plot inputs

After Folder 1 completes, you can run other folders as needed. See [REPRODUCTION_GUIDE.md](REPRODUCTION_GUIDE.md) for the complete workflow.

**Quick run**: Use `RUN_ALL.m` to execute everything automatically.

---

### Q2: Which scripts generate the violin plot input files?

**A:** The script `g_ClassificationFiles.m` (in Folder 1) generates all three files:
- `asymp.csv`
- `rev_SAkilling.csv`
- `irrev_SAkilling.csv`

These files are created from `AllVirtualPatientTypes.csv` by separating patients based on their stable states.

**Important**: Do NOT use `One_StableState.csv`, `Two_StableStates.csv`, or `ThreeOrMore_StableStates.csv` as inputs for violin plots. These are intermediate files.

---

### Q3: Is there a mapping between scripts and figures?

**A:** Yes! See the Figure Generation Map in [REPRODUCTION_GUIDE.md](REPRODUCTION_GUIDE.md#figure-generation-map).

Quick reference for main figures:
- **Figure 1**: [Folder/scripts]
- **Figure 2**: [Folder/scripts]
- **Figure 3** (Violin plots): Folder 7, `g_ViolinPlots.m`
- **Supplementary Figures**: See complete table in REPRODUCTION_GUIDE.md

---

## Data File Questions

### Q4: What are the 26 columns in AllVirtualPatientTypes.csv?

**A:** Full details in [DATA_DICTIONARY.md](DATA_DICTIONARY.md), but here's the summary:

| Columns | Content |
|---------|---------|
| 1-17 | Model parameters (see Table S1 in paper) |
| 18-20 | Steady states: A* (SA), E* (SE), B* (barrier) |
| 21-23 | Eigenvalues: λ₁, λ₂, λ₃ (stability analysis) |
| 24 | Patient type: 0 (Asymp), 1 (Rev), 2 (Irrev) |
| 25 | Region: 1-9 (see Supplementary Note 3) |
| 26 | [Additional classification if used] |

---

### Q5: Should I use AllVirtualPatientTypes.csv or the separate CSV files?

**A:** It depends on what you're doing:

**Use AllVirtualPatientTypes.csv** if:
- You want to do custom analysis
- You need all patient data together
- You're exploring the dataset

**Use the three separate files** (asymp.csv, rev_SAkilling.csv, irrev_SAkilling.csv) if:
- You're generating violin plots
- You need patients already separated by type
- You're reproducing Figure 3 from the paper

---

## Classification Questions

### Q6: How exactly are patients classified into the three categories?

**A:** Based on the barrier function (B*) in their stable states:

| Category | Code | B* = 1 states? | B* < 1 states? | Interpretation |
|----------|------|----------------|----------------|----------------|
| **Asymptomatic** | 0 | ✓ Yes (only) | ✗ No | Healthy skin only |
| **Reversible** | 1 | ✓ Yes | ✓ Yes | Can be healthy or damaged |
| **Irreversible** | 2 | ✗ No | ✓ Yes (only) | Always damaged |

**Technical note**: B* = 1 means `abs(B* - 1.0) < 1e-6` (floating-point precision)

---

### Q7: How do the nine regions map to the categories 0/1/2?

**A:** Regions (Column 25) and Types (Column 24) are **independent classifications**:

- **Regions** (1-9) describe *where* the stable state is in SA/SE/B* space
- **Types** (0/1/2) describe *how many types* of stable states exist (healthy vs damaged)

A patient can have multiple stable states in different regions. The Type classification looks at **all** their stable states together:
- If all states have B*=1 → Type 0 (doesn't matter which regions)
- If some states have B*=1 and some B*<1 → Type 1
- If all states have B*<1 → Type 2 (doesn't matter which regions)

See [DATA_DICTIONARY.md](DATA_DICTIONARY.md#region-classifications-column-25) for region definitions.

---

### Q8: How should I handle patients with three or more stable states?

**A:** Use the same classification rules:
1. Check if ANY stable state has B* ≈ 1 (healthy)
2. Check if ANY stable state has B* < 1 (damaged)
3. Classify based on presence:
   - Only healthy states → Type 0
   - Both types present → Type 1
   - Only damaged states → Type 2

The number of stable states doesn't matter for Type classification, only whether healthy and/or damaged states exist.

---

### Q9: What about region 8/9 or cases like 5-5?

**A:** 

**Regions 8/9**: [Explain your specific handling - are they merged? separate? how?]

**Same-region multiple states (e.g., 5-5)**: When a patient has two stable states both in the same region:
- This is possible and valid
- They differ in stability or other characteristics
- Type classification uses the rule: [specify your rule]
- Example: If one is B*=1 and one is B*=0.7, both in region 5 → Type 1 (reversible)

---

## Technical Issues

### Q10: I get "File not found" errors. What should I do?

**A:** Common causes:

1. **Wrong directory**: Ensure you're running scripts from their respective folders
   ```matlab
   cd '1. Analyse steady states'  % Navigate first
   run g_samples.m                 % Then run
   ```

2. **Missing previous output**: Make sure you've run earlier steps
   - `a_SampledParameters.m` needs output from `g_samples.m`
   - Check that expected `.mat` or `.csv` files exist

3. **Filename mismatch**: Check if your files use `.mat` or `.csv` extensions
   - Scripts may need adjustment for your specific filenames

**Solution**: Use `RUN_ALL.m` to ensure correct execution order.

---

### Q11: I'm running out of memory. What can I do?

**A:** The 1 million parameter sets require significant RAM:

**Short-term solutions**:
- Close other applications
- Restart MATLAB to clear memory
- Process in batches (see Q12)

**Long-term solutions**:
- Use a machine with at least [X] GB RAM
- Modify scripts to process data in chunks
- Use memory-efficient data types

---

### Q12: Can I run with fewer than 1 million parameter sets?

**A:** Yes, for testing purposes:

```matlab
% In g_samples.m, modify:
n_samples = 100000;  % Instead of 1000000

% Note: Results will differ from paper
% Only use for testing workflow, not for publication
```

For reproduction of published results, use the full 1 million samples.

---

### Q13: The scripts take too long. Is this normal?

**A:** Yes, the complete workflow can take several hours:

**Typical runtimes** (on [specify hardware]):
- `g_samples.m`: ~[X] minutes
- `a_SampledParameters.m`: ~[X] minutes (longest step)
- `g_VirtualPatients.m`: ~[X] minutes
- `a_PatientGroups.m`: ~[X] minutes
- Total: ~[X] hours

**Tips**:
- Run overnight or on a computing cluster
- Use `RUN_ALL.m` which shows progress
- Monitor with `top` or Task Manager

---

## Results Interpretation

### Q14: My results are slightly different from the paper. Is this a problem?

**A:** Small differences are expected due to:

1. **Random sampling**: If using different random seeds
2. **MATLAB version**: Slight numerical differences
3. **Numerical precision**: Floating-point variations

**Significant differences** might indicate:
- Incorrect script execution order
- Missing steps
- Wrong parameter ranges

**To verify**: Check that your proportions of Types 0/1/2 match the paper within ~1-2%.

---

### Q15: How do I interpret the violin plots?

**A:** The violin plots show the distribution of [specify what parameter] across the three patient types:

- **X-axis**: Patient type (Asymp, Rev, Irrev)
- **Y-axis**: [Parameter being compared]
- **Width**: Density of patients at that value
- **Internal box**: Median and quartiles

**Biological interpretation**: [Add your interpretation]

See Figure 3 caption in the paper for detailed explanation.

---

### Q16: What if I want to analyze a different parameter or subset?

**A:** You can:

1. **Modify the classification rules** in `g_ClassificationFiles.m`
2. **Create custom filters** on `AllVirtualPatientTypes.csv`
3. **Analyze specific regions** by filtering on Column 25
4. **Compare different parameters** by modifying violin plot scripts

Example - extract only Region 5 patients:
```matlab
data = readmatrix('AllVirtualPatientTypes.csv');
region5 = data(data(:,25) == 5, :);
```

---

## Still Need Help?

If your question isn't answered here:

1. **Check documentation**:
   - [REPRODUCTION_GUIDE.md](REPRODUCTION_GUIDE.md) - Complete workflow
   - [DATA_DICTIONARY.md](DATA_DICTIONARY.md) - Data specifications
   - README.md - Quick start guide

2. **Review the paper**:
   - Main text for biological context
   - Supplementary Materials for technical details
   - Table S1 for parameter definitions

3. **Get support**:
   - Open an issue on GitHub
   - Contact: [your email]
   - Check for existing issues that might answer your question

---

## Common Pitfall Checklist

Before asking for help, verify you:

- [ ] Ran scripts in the correct order (see Q1)
- [ ] Are using the correct input files (see Q2, Q5)
- [ ] Have all required outputs from previous steps
- [ ] Are running scripts from their respective folders
- [ ] Have sufficient RAM and disk space (see Q11)
- [ ] Used the full 1 million samples (see Q12)
- [ ] Checked MATLAB version compatibility

---

**Last Updated**: [Date]  
**Version**: 1.0

**Contribute**: Found an error or have a suggestion? Open a pull request or issue on GitHub!