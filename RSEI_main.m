%%%基于语义的归一化互信息熵

%%参数设定
%设定超像素个数
K = 5;
%设定超像素紧凑系数
m_compactness = 20;
img_num = 1;

for img_index = 1:1
HR_path = strcat('F:\研究生\数据集\遥感影像\test\1.tif');
LR_path = strcat('F:\研究生\ME\论文\MSRSR\数据\msrsr\1.png');
img = imread(HR_path);
img_size = size(img);   %三个元素：图像的高、图像的宽、图像的通道数

%转换到LAB色彩空间
cform = makecform('srgb2lab');       %rgb空间转换成lab空间 matlab自带的用法
img_Lab = applycform(img, cform);    %rgb转换成lab空间
%img_Lab = RGB2Lab(img);  %不好用不知道为什么
% imshow(img_Lab)
% %检测边缘
% img_edge = DetectLabEdge(img_Lab);
% imshow(img_edge)
%得到超像素的LABXY种子点信息
img_sz = img_size(1)*img_size(2);
superpixel_sz = img_sz/K;
STEP = uint32(sqrt(superpixel_sz));
xstrips = uint32(img_size(2)/STEP);
ystrips = uint32(img_size(1)/STEP);
xstrips_adderr = double(img_size(2))/double(xstrips);
ystrips_adderr = double(img_size(1))/double(ystrips);
numseeds = xstrips*ystrips;
%种子点xy信息初始值为晶格中心亚像素坐标
%种子点Lab颜色信息为对应点最接近像素点的颜色通道值
kseedsx = zeros(numseeds, 1);
kseedsy = zeros(numseeds, 1);
kseedsl = zeros(numseeds, 1);
kseedsa = zeros(numseeds, 1);
kseedsb = zeros(numseeds, 1);
n = 1;
for y = 1: ystrips
    for x = 1: xstrips 
        kseedsx(n, 1) = (double(x)-0.5)*xstrips_adderr;
        kseedsy(n, 1) = (double(y)-0.5)*ystrips_adderr;
        kseedsl(n, 1) = img_Lab(fix(kseedsy(n, 1)), fix(kseedsx(n, 1)), 1);
        kseedsa(n, 1) = img_Lab(fix(kseedsy(n, 1)), fix(kseedsx(n, 1)), 2);
        kseedsb(n, 1) = img_Lab(fix(kseedsy(n, 1)), fix(kseedsx(n, 1)), 3);
        n = n+1;
    end
end
n = 1;
%根据种子点计算超像素分区
klabels = PerformSuperpixelSLIC(img_Lab, kseedsl, kseedsa, kseedsb, kseedsx, kseedsy, STEP, m_compactness);
img_Contours = DrawContoursAroundSegments(img, klabels);
% imshow(img_Contours)
%合并小的分区
nlabels = EnforceLabelConnectivity(img_Lab, klabels, K); 
img1 = imread(LR_path);%低分辨率图片
toc
for label =1:max(max(nlabels))
% for label =14:14
    new_nlabels = nlabels;
    new_nlabels(new_nlabels~= label) = 0;
    new_nlabels1 = new_nlabels ;
    new_nlabels1(new_nlabels1== label) = 1;
    img_1 = img;
    img_2 = img1;
    img_y1 = img;
    img_y2 = img1;
    img_y1 = rgb2ycbcr(img_y1);
    img_y2 = rgb2ycbcr(img_y2);
    img_y1 = double(img_y1);
    img_y2 = double(img_y2);
    new_nlabels2 = logical(new_nlabels1);
    [r c]=find(new_nlabels2==1);
    [rectx,recty,area,perimeter] = minboundrect(c,r,'a'); 
    new_nlabels2=roipoly(new_nlabels2,rectx,recty);
%     imshow(new_nlabels2);hold on
%     new_nlabels1 = labelfilling(new_nlabels1);
    img_y11 = img_y1(:,:,1).*new_nlabels2;
    img_y21= img_y2(:,:,1).*new_nlabels2;
    %%去除非0的行列
    img_y11(all(img_y11 == 0, 2),:)=[];
    img_y21(all(img_y21 ==0, 2),:)=[];
    img_y11(:,all(img_y11 == 0, 1))=[];
    img_y21(:,all(img_y21 == 0, 1))=[];
    [Ha, mi_sum] = MI(img_y11,img_y21);
    Ha_l(label) = Ha;
    mi_sum_l(label) = mi_sum;
end
Ha_sum = sum(Ha_l);
new_Ha = Ha_l /Ha_sum;
pic_MI(img_index) = sum(new_Ha .* mi_sum_l);
end
toc
fprintf('-------------------- \n');
fprintf('RSEI : %f \n', mean(pic_MI,2));


        
        






