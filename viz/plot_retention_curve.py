import duckdb
import matplotlib.pyplot as plt

con = duckdb.connect('voy_ae_case_study/dev.duckdb')

df = con.sql("""
    select
        cohort_month,
        months_since_acquisition,
        sum(active_customers) as active_customers,
        sum(cohort_size) as cohort_size
    from mart_cohort_retention
    where months_since_acquisition between 0 and 12
    group by 1, 2
""").df()

df['retention_rate'] = df['active_customers'] / df['cohort_size']

cohorts_to_plot = sorted(df['cohort_month'].unique())[::max(1, len(df['cohort_month'].unique()) // 8)]

fig, ax = plt.subplots(figsize=(10, 6))
for cohort in cohorts_to_plot:
    sub = df[df['cohort_month'] == cohort].sort_values('months_since_acquisition')
    ax.plot(sub['months_since_acquisition'], sub['retention_rate'] * 100, marker='o', label=str(cohort)[:7])

ax.set_xlabel('Months since acquisition')
ax.set_ylabel('Retention rate (%)')
ax.set_title('Cohort Retention Curve')
ax.legend(title='Cohort', fontsize=8, loc='upper right')
ax.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('docs/retention_curve.png', dpi=150)
print("Saved to docs/retention_curve.png")