clc
clear

% ������������
n = 8;  % ����λ��
<<<<<<< HEAD:polar_concatenated_CRC/polar_SC_256N.m
R = 0.5;    % ����
SNR = 1:0.5:3;
=======
<<<<<<< HEAD
R = 0.5;    % ����
SNR = -1:4;
=======
R = 0.2188;    % ����
SNR = -3:2;
>>>>>>> bfe068ca293afe9ca8ef278f563e447513a91e26
>>>>>>> 49065cad14f2d75d62e7e1b1f58b32cd5a99e729:polar_concatenated_CRC/polar_compare_SC.m
block_num = 10000;

% ��������
snr = 10.^(SNR/10);
esn0 = snr * R;
N = 2^n;
K = floor(N*R);  % information bit length
k_f = N - K;

% get information bits and concatenated bits
load('Pe_snr3p0db_2048_n_8.mat');   % load the channel information
[Ptmp, I] = sort(P);
Info_index = sort(I(K:-1:1));  % ��ѡ�����õ��ŵ�������Ϣλ
Frozen_index = sort(I(end:-1:K+1));   % ���䶳��λ���ŵ�

% get generate matrix
G = encoding_matrix(n);
Gi = G(Info_index,:);
Gf = G(Frozen_index,:);
frozen_bits = zeros(1,k_f);
rng('shuffle')
for i = 1:length(SNR)
    sigma = (2*esn0(i))^(-0.5);
    % set PER and BER counter
    PerNum = 0;
    BerNum = 0;
    for iter = 1:block_num
        fprintf('\nNow iter: %2d\tNow SNR: %d', iter, SNR(i));
        source_bit = randi([0 1],1,K);
        encode_temp = rem(source_bit*Gi + frozen_bits*Gf,2);
    
        % bpsk modulation
        encode_temp = (-1).^(encode_temp + 1);
        % add noise
        receive_sample = encode_temp + sigma * randn(size(encode_temp));
        
        [receive_bits, ~] = polarSC_decoder(n,receive_sample,sigma,Frozen_index,frozen_bits,Info_index);
        
        % calculate BER and PER
%         error_index = find(receive_bits ~= source_bit);
%         fprintf('\nNow error index: %3d\t The error lr: ',error_index);
%         disp(info_lr(error_index));
        count = sum(receive_bits ~= source_bit);
        if count ~= 0
            PerNum = PerNum + 1;
            BerNum = BerNum + count;
        end 
    end
    perSC(i) = PerNum/block_num;
    berSC(i) = BerNum/(K*block_num);
end