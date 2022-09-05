clc;
clear all;
data_root = '../pos';
write_root = '../pos_cm200';
CPU_cores = 8;
alpha = 1.5; % not useful
gamma = 0.08;
beta = 120; % parameter to be tunned
patient_dir = dir(data_root);
n_patients = length(patient_dir) - 2;
disp(['number of patients: ' num2str(n_patients)]);

if ~exist(write_root, 'dir')
    mkdir(write_root);
end

poolobj = parpool('local', CPU_cores);

parfor i = 1:n_patients
    disp(['processing ' num2str(i) '-th patient, ID:' patient_dir(i + 2).name])
    patient_path = fullfile(data_root, patient_dir(i + 2).name);
    write_patient_path = fullfile(write_root, patient_dir(i + 2).name);

    if ~exist(write_patient_path, 'dir')
        mkdir(write_patient_path);
    end

    volume_dir = dir(fullfile(patient_path, '*volume*.nii'));

    for j = 1:length(volume_dir)
        volume_path = fullfile(patient_path, volume_dir(j).name);
        disp(['processing ' num2str(j) '-th volume, directory:' volume_path])
        volume = niftiread(volume_path); % width height frame
        s = size(volume);
        pred_map = zeros([s(3) s(2) s(1)], 'uint8');

        for k = 1:size(volume, 3)
            img = volume(:, :, 1);
            img = rot90(img);
            [map] = confMap(img, alpha, beta, gamma);
            pred_map(k, :, :) = uint8(map * 255);
        end

        write_nii_path = fullfile(write_patient_path, ['cm_' volume_dir(j).name]);
        niftiwrite(pred_map, write_nii_path);
    end

end

delete(poolobj);
