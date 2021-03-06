%{
listing=dir('/home/aka/Ubuntu/Project/SMAI/actual/Font/*');
sz=size(listing);
sz=sz(1);
charit=[];
for i=3:12
    charit(i)=i-3;
end
sit = upper('abcdefghijklmnopqrstuvwxyz');

for i=13:38
    charit(i)=sit(i-12);
end

sit=lower(sit);
for i=39:64
    charit(i)=sit(i-38);
end

mat=zeros(70*1200,9);
cnt=1;
chit=zeros(70*1500,1);
for i=3:64
    varit='/home/aka/Ubuntu/Project/SMAI/actual/Font/';
    varit=strcat(varit,listing(i).('name'));
    img=dir(varit);
    szit=size(img);
    szit=szit(1);
    %mat=zeros(szit,10);
    szit=szit/10;
    for j=3:szit
        imgname=strcat(varit,'/');
        imgname=strcat(imgname,img(j).('name'));
        
        %Calculate Invariant moments
        valit=feature_vec(imgname);
        doit=size(valit);
        doit=doit(1);
        p=valit';
        mat(cnt,1:7)=p;
        
        %Calculate Zenrik's code
        valit=Zernike_main(imgname);
        mat(cnt,8:9)=valit;
        chit(cnt,1)=charit(i);
        cnt=cnt+1;
    end
end

cnt=cnt-1;
mat=mat(1:cnt,1:9);
chit=chit(1:cnt);
modelit=multisvm_train(mat,chit);


dlmwrite('matit.txt',mat);
dlmwrite('chit.txt',chit);
%}
%sprintf(mat);

p=dlmread('p.txt');
t=dlmread('t.txt');
mytree=treefit(p, t, 'splitmin', 2);
%treedisp(mytree);
%modelit=multisvm_train(mat,chit);



for iiit=1:1000

prompt = 'Enter the file path of the input file : ';
str = input(prompt, 's');
if strcmp(str,'quit')==1
    break;
end
I = imread(str);
I0 = ~im2bw(I, 0.3);
I = rgb2gray(I);
figure;
imshow(I0);

CC = bwconncomp(I0, 8);
se1 = strel('diamond', 2);
se2 = strel('diamond', 1);
if CC.NumObjects > 10
    I0 = imdilate(I0, se1);
    I0 = imerode(I0, se2);
    CC = bwconncomp(I0, 8);
end
I1 = bwlabel(I0, 8);
figure;
imshow(I1, []);

I2 = label2rgb (I1, 'hsv', 'k', 'shuffle');
figure;
imshow(I2, []);
pk = [];
M = regionprops(I1, I, 'all');
for k = 1 : CC.NumObjects           % Loop through all blobs.
    % Find the bounding box of each blob.
	thisBlobsBoundingBox = M(k).BoundingBox;  % Get list of pixels in current blob.
	% Extract out this coin into it's own image.
	subImage = imcrop(I0, thisBlobsBoundingBox);
    C1 = bwconncomp(subImage, 8);
    numPixels = cellfun(@numel,C1.PixelIdxList);
    [biggest,idx] = max(numPixels);
    for i = 1:C1.NumObjects
        if i ~= idx
            subImage(C1.PixelIdxList{i}) = 0;
        end
    end
	 %Display the image with informative caption.
	figure;
    
    % Getting the image complement
    h = fspecial('unsharp');
    binary_image = subImage;
    binary_image = imfilter(binary_image, h, 'replicate');

    try
        % Extracting the features from the image
        pk(end + 1, :) = hierarchicalCentroid(binary_image, 4, 0);
    catch
        'Exception occured';
    end
    %calculating 7 transforms
    %matit=zeros(1,7);
    %valit=feature_vec(imgname);
    %doit=size(valit);
    %doit=doit(1);
    %p=valit';
    %matit(1,1:7)=p;
    
    %calculating Zernik's moments
    %{
    valit=Zernike_main(imgname);
    matit(1,8:9)=valit;
    %}
        
    imshow(subImage);
    
    %result=svmclassifier(matit,modelit,chit);
end
estimate1=treeval(mytree,pk);
disp(estimate1);

labelnew = knnclassifier(1,p,pk,t,k)
disp(labelnew);
end