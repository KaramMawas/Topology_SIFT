% Topology 
% Karam Mawas	    	

clear all
close all
clc

load data

im1 = imread('E:\UNI\UNI\Third semester\Topology and Optimization\Labs\Lab1/Image1.tif');
im2 = imread('E:\UNI\UNI\Third semester\Topology and Optimization\Labs\Lab1/Image2.tif');


% Initializing assignments of the SIFT-points

u = size(matches);

% creat a cost matrix with inf. values (or inf. costs)
Perf=inf(492,459);

% set the size of the matrix in advance in order to reduce the time inside
% the loop
feature_Im1 = zeros(u(:,1),128);
feature_Im2 = zeros(u(:,1),128);
coord_im1 = zeros(u(:,1),2);
coord_im2 = zeros(u(:,1),2);

for i = 1:u(:,1);
    t = matches(i,:);
    feature_Im1(i,:) = Keypoints_Descr_Im1(t(:,1),:);
    feature_Im2(i,:) = Keypoints_Descr_Im2(t(:,2),:);
    % calculation of the cost value (the distance)
    dist = sqrt(sum((feature_Im1(i,:)-feature_Im2(i,:)).^2,2));
    % Inserting the cost values into the cost matrix
    Perf(t(1,1),t(1,2)) = dist;
    % getting the matched points coordinates
    coord_im1(i,:) = Keypoints_Coord_Im1(t(:,1),:);
    coord_im2(i,:) = Keypoints_Coord_Im2(t(:,2),:);
    
end


% to test the cost matrix if the inserting equla to the num. of rows of 
% the matches matrix
% Find the number in each row that are not Inf
not_inf = sum(~isinf(Perf),2);
not_inf_value = sum(not_inf);

% apply the Hungarian algorithm
[Matching,Cost] = Hungarian(Perf);

% checking how many matching has been lefted after the algorithm
num_matching = sum(Matching);
num_matching_value = sum(num_matching,2);

% the diff. between
diff = not_inf_value - num_matching_value;
diff_percent = (num_matching_value*100)/not_inf_value;

% ********************************************************************
% getting the coordinates of the points after the Hungarian algorithm
% ********************************************************************

% to find the corresponding column and row for each true value
[img1 img2] = find(Matching==1);

% set the size of the matrix in advance in order to reduce the time inside
% the loop
coord_im1_Hungarian = zeros(num_matching_value,2);
coord_im2_Hungarian = zeros(num_matching_value,2);

for i=1:num_matching_value
    coord_im1_Hungarian(i,:) = Keypoints_Coord_Im1(img1(i),:);
    coord_im2_Hungarian(i,:) = Keypoints_Coord_Im2(img2(i),:);
end

    
% ********************************************************************
% Display
% ********************************************************************

% Concatenate the images
img_comb = [im1 im2];
% by this way the images are beside each other here we
% have to notice that the coordinates of the second image should be shifted
% in the x_axis by the length of the columns of the first image 
% which is 402 columns.

% correcting the x coordinates of the second image
coord_im2 = [coord_im2(:,1)+402,coord_im2(:,2)];
coord_im2_Hungarian = [coord_im2_Hungarian(:,1)+402,coord_im2_Hungarian(:,2)];

% plotting

% Plot Just from the SIFT
% first image points
f1 = figure;
imshow(img_comb);
hold on;

h1 = plot (coord_im1(:,1),coord_im1(:,2),'o');
% second image points
h2 = plot (coord_im2(:,1),coord_im2(:,2),'o');
% the matching
for i=1:not_inf_value
    x = [coord_im1(i,1),coord_im2(i,1)];
    y = [coord_im1(i,2),coord_im2(i,2)];
    h3 = plot (x,y,'-r');
end
set(f1,'NumberTitle','On','Name','Matching SIFT');
title ('\bf Matching SIFT ');
n = legend([h1 h3],{'Points','Matching SIFT'});
set(n,'FontAngle','italic','TextColor',[0 0 0],'position',[0.81 0.83 0.1 0.1]);
saveas(f1,sprintf('Matching SIFT%d.png',0));

% plotting together

f = figure;
imshow(img_comb);
hold on;

% before the algorithm

% first image points
p1 = plot (coord_im1(:,1),coord_im1(:,2),'o');
% second image points
p2 = plot (coord_im2(:,1),coord_im2(:,2),'o');
% the matching
for i=1:not_inf_value
    x = [coord_im1(i,1),coord_im2(i,1)];
    y = [coord_im1(i,2),coord_im2(i,2)];
    p3 = plot (x,y,'-r');
end

% after the hungarian algorithm

P4 = plot (coord_im1_Hungarian(:,1),coord_im1_Hungarian(:,2),'o');
% second image points
p5 = plot (coord_im2_Hungarian(:,1),coord_im2_Hungarian(:,2),'o');
% the matching
for i=1:num_matching_value
    x = [coord_im1_Hungarian(i,1),coord_im2_Hungarian(i,1)];
    y = [coord_im1_Hungarian(i,2),coord_im2_Hungarian(i,2)];
    p6 = plot (x,y,'-g');
end
set(f,'NumberTitle','On','Name','Matching Hungarian');
title (['\bf The matching after the Hungarian algorithm ',num2str(diff_percent),'\bf%']);
l = legend([p1 p3 p6],{'Points','Matching SIFT','Updated matching Hungarian'});
set(l,'FontAngle','italic','TextColor',[0 0 0],'position',[0.81 0.83 0.1 0.1]);
saveas(f,sprintf('Matching Hungarian%d.png',0));

