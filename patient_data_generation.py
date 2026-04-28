import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

--- create seed for reproducibility
np.random.seed(42)

--- set parameters
num_patients = 5000
start_date = datetime(2023, 1, 1)
end_date = datetime(2024, 1, 1)

---- 1. generates Patients Table
diagnoses = ['PCOS', 'Perimenopause', 'Menopause', 'Endometriosis', 'Hypothyroidism']
states = ['MA', 'NY', 'CA', 'TX', 'FL', 'IL']

patients_data = {
    'patient_id': [f'P{str(i).zfill(5)}' for i in range(1, num_patients + 1)],
    'join_date': [start_date + timedelta(days=random.randint(0, 365)) for _ in range(num_patients)],
    'age': np.random.normal(loc=38, scale=10, size=num_patients).astype(int), # Average age 38
    'state': np.random.choice(states, num_patients),
    'primary_diagnosis': np.random.choice(diagnoses, num_patients, p=[0.3, 0.25, 0.2, 0.15, 0.1])
}

df_patients = pd.DataFrame(patients_data)

---- 2. Generate Funnel & Retention Events Table
---- Steps: 1_Account_Created -> 2_Intake_Completed -> 3_Provider_Matched -> 4_First_Visit -> 5_Follow_Up_Month_1 -> etc.
events_list = []

for index, row in df_patients.iterrows():
    pid = row['patient_id']
    base_date = row['join_date']
    
    # Step 1: Account Created (100% of patients)
    events_list.append((pid, '1_Account_Created', base_date))
    
    # Step 2: Intake Completed (85% conversion)
    if random.random() < 0.85:
        base_date += timedelta(days=random.randint(0, 2))
        events_list.append((pid, '2_Intake_Completed', base_date))
        
        # Step 3: Provider Matched (90% conversion from Intake)
        if random.random() < 0.90:
            base_date += timedelta(days=random.randint(1, 5))
            events_list.append((pid, '3_Provider_Matched', base_date))
            
            # Step 4: First Visit (80% conversion from Match)
            if random.random() < 0.80:
                base_date += timedelta(days=random.randint(2, 14))
                events_list.append((pid, '4_First_Visit', base_date))
                
                # Retention: Follow-up visits (Months 1, 2, 3)
                retention_probs = [0.70, 0.50, 0.40] # Decay over time
                for month, prob in enumerate(retention_probs, start=1):
                    if random.random() < prob:
                        visit_date = base_date + timedelta(days=30 * month + random.randint(-5, 5))
                        # Cap at current date simulation
                        if visit_date < end_date + timedelta(days=90): 
                            events_list.append((pid, f'Visit_Month_{month}', visit_date))

df_events = pd.DataFrame(events_list, columns=['patient_id', 'event_name', 'event_date'])

# Export to CSV for SQL ingestion
df_patients.to_csv('patients.csv', index=False)
df_events.to_csv('events.csv', index=False)
print("Datasets generated successfully.")
