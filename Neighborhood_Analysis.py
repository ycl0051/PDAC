#!/usr/bin/env python
# coding: utf-8
# Author: YangChenlu

import itertools

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

#### create dic {bin:nmf}
adjusted_dict = {}
for key, values in result_dict.items():
    for value in values:
        if value not in adjusted_dict:
            adjusted_dict[value] = []
        adjusted_dict[value].append(key)

#### Calculate distance 
nmf_numbers = list(result_dict.keys())
with open('coordinates_distance_w0.4.txt', 'w') as file:
    for nmf_number1, nmf_number2 in itertools.product(nmf_numbers, repeat=2):
        percent_nmf = 0
        for coordinates in result_dict[nmf_number1]:
            x, y = coordinates.split(",")
            current_coordinates = []
            for i in range(int(x) - 1, int(x) + 2):
                for j in range(int(y) - 1, int(y) + 2):
                    if i == int(x) and j == int(y):
                        continue  # exclude center spot
                    current_coordinates.append(str(i) + ',' + str(j))        
            # calculate the proportion of bins in one NMF module around one of the bins in the target NMF
            total_count = 0
            nmf_count = 0
            for i in range(0,8):
                total_count += len(adjusted_dict.get(current_coordinates[i], []))
                if nmf_number2 in adjusted_dict.get(current_coordinates[i], []):
                    nmf_count += 1
            if total_count >0:
                percent_nmf += nmf_count/total_count
        percent = percent_nmf/len(result_dict[nmf_number1])
        print(nmf_number1,nmf_number2,percent)
        file.write(f"{nmf_number1} {nmf_number2} {percent}\n")

# Heatmap plots were done in R
