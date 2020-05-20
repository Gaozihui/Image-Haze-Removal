clear all
clc
close all
img=imread('test images/haze5.jpg');
figure,imshow(uint8(img)), title('original');
kenlRatio = .01;
minAtomsLight = 240;
sz=size(img);

w=sz(2);%width

h=sz(1);%height

dc = zeros(h,w);

for y=1:h

    for x=1:w

        dc(y,x) = min(img(y,x,:));

    end

end %找出RGB通道中的最小的


%figure,imshow(uint8(dc)), title('Min(R,G,B)');

krnlsz = floor(max([3, w*kenlRatio, h*kenlRatio]));

krnlsz=2;
dc2 = minfilt2(dc, [krnlsz,krnlsz]);

dc2(h,w)=0;

%figure,imshow(uint8(dc2)), title('After filter ');

t = 255 - 0.8*dc2;

%figure,imshow(uint8(t)),title('t');

t_d=double(t)/255;

sum(sum(t_d))/(h*w);


A = min([minAtomsLight, max(max(dc2))])

J = zeros(h,w,3);

img_d = double(img);

J(:,:,1) = (img_d(:,:,1) - (1-t_d)*A)./t_d;

J(:,:,2) = (img_d(:,:,2) - (1-t_d)*A)./t_d;

J(:,:,3) = (img_d(:,:,3) - (1-t_d)*A)./t_d;

%figure,imshow(uint8(J)), title('J');
% figure,imshow(rgb2gray(uint8(abs(J-img_d)))), title('J-img_d');
% a = sum(sum(rgb2gray(uint8(abs(J-img_d))))) / (h*w)
% return;
%----------------------------------
r = krnlsz*4;
eps = 10^-6;
I=double(rgb2gray(img));
[hei, wid] = size(I);
p=t_d;
N = boxfilter(ones(hei, wid), r);
mean_I = boxfilter(I, r) ./ N;
mean_p = boxfilter(p, r) ./ N;
mean_Ip = boxfilter(I.*p, r) ./ N;
cov_Ip = mean_Ip - mean_I .* mean_p; % this is the covariance of (I, p) in each local patch.

mean_II = boxfilter(I.*I, r) ./ N;
var_I = mean_II - mean_I .* mean_I;

a = cov_Ip ./ (var_I + eps); % Eqn. (5) in the paper;
b = mean_p - a .* mean_I; % Eqn. (6) in the paper;

mean_a = boxfilter(a, r) ./ N;
mean_b = boxfilter(b, r) ./ N;

q = mean_a .* I + mean_b; 

filtered = q;


t_d = filtered;

%figure,imshow(t_d,[]),title('filtered t');

J(:,:,1) = (img_d(:,:,1) - (1-t_d)*A)./t_d;

J(:,:,2) = (img_d(:,:,2) - (1-t_d)*A)./t_d;

J(:,:,3) = (img_d(:,:,3) - (1-t_d)*A)./t_d;
img_d(1,3,1)
figure,imshow(uint8(J)), title('result');
