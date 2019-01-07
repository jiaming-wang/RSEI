%%%��������Ĺ�һ������Ϣ��

%%�����趨
%�趨�����ظ���
K = 5;
%�趨�����ؽ���ϵ��
m_compactness = 20;
img_num = 1;

for img_index = 1:1
HR_path = strcat('F:\�о���\���ݼ�\ң��Ӱ��\test\1.tif');
LR_path = strcat('F:\�о���\ME\����\MSRSR\����\msrsr\1.png');
img = imread(HR_path);
img_size = size(img);   %����Ԫ�أ�ͼ��ĸߡ�ͼ��Ŀ�ͼ���ͨ����

%ת����LABɫ�ʿռ�
cform = makecform('srgb2lab');       %rgb�ռ�ת����lab�ռ� matlab�Դ����÷�
img_Lab = applycform(img, cform);    %rgbת����lab�ռ�
%img_Lab = RGB2Lab(img);  %�����ò�֪��Ϊʲô
% imshow(img_Lab)
% %����Ե
% img_edge = DetectLabEdge(img_Lab);
% imshow(img_edge)
%�õ������ص�LABXY���ӵ���Ϣ
img_sz = img_size(1)*img_size(2);
superpixel_sz = img_sz/K;
STEP = uint32(sqrt(superpixel_sz));
xstrips = uint32(img_size(2)/STEP);
ystrips = uint32(img_size(1)/STEP);
xstrips_adderr = double(img_size(2))/double(xstrips);
ystrips_adderr = double(img_size(1))/double(ystrips);
numseeds = xstrips*ystrips;
%���ӵ�xy��Ϣ��ʼֵΪ������������������
%���ӵ�Lab��ɫ��ϢΪ��Ӧ����ӽ����ص����ɫͨ��ֵ
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
%�������ӵ���㳬���ط���
klabels = PerformSuperpixelSLIC(img_Lab, kseedsl, kseedsa, kseedsb, kseedsx, kseedsy, STEP, m_compactness);
img_Contours = DrawContoursAroundSegments(img, klabels);
% imshow(img_Contours)
%�ϲ�С�ķ���
nlabels = EnforceLabelConnectivity(img_Lab, klabels, K); 
img1 = imread(LR_path);%�ͷֱ���ͼƬ
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
    %%ȥ����0������
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


        
        






