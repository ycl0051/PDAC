#!/usr/bin/env python
# coding: utf-8
# Author: YangChenlu

#### create dic {nmf:bin}
with open('nmf_h_matrix.txt', 'r') as file:
    lines = file.readlines()
    column_names = lines[0].strip().split('\t')
    result_dict = {}
    for line in lines[1:]:
        values = line.strip().split('\t')  
        row_name = values[0] 
        #sorted_data = sorted(values[1:], key=lambda x: float(x[0]), reverse=True)
        sorted_data = sorted(zip(values[1:], column_names[1:]), key=lambda x: float(x[0]), reverse=True)
        sorted_values, sorted_cols = zip(*sorted_data)  
        cumulative_sum = 0  
        selected_cols = []  
        for value in sorted_values:
            cumulative_sum += float(value)
            if cumulative_sum <= 0.4:   # whether the sum is greater than 0.4
                selected_cols.append(sorted_cols[sorted_values.index(value) + 1])     
            else:
                break
        result_dict[row_name] = selected_cols

#### output
df = pd.DataFrame(list(result_dict.items()), columns=['Key', 'Value'])
df['Value'] = df['Value'].astype(str)
df['Value'] = df['Value'].str.replace('[', '').str.replace(']', '').str.replace("'",'')
txt_file_path = 'nmf_cutoff_sum0.4_binnames.txt'
df.to_csv(txt_file_path, sep='\t', index=False, header=None)
