function model=CreateModel(pic)

    % Read DEM data
    H1 = imread('n29_e098_1arc_v1.tif');  % Get the elevation data
    H1 = H1(1:3600,1:3600);
    H1 = flip(H1,2);
    H1_ele = zeros(300,300);
    for i = 1:300
        for j = 1:300
            temp_ele = H1(((i-1)*12+1):i*12,((j-1)*12+1):j*12);
            H1_ele(i,j) = mean(temp_ele,'all');
        end
    end
    K = (1/50)*ones(7);

    H1_smooth = conv2(H1_ele,K,'same');
    MAPSIZE_X = 300;  % x index: columns of H
    MAPSIZE_Y = 300;  % y index: rows of H 
    [X,Y] = meshgrid(1:MAPSIZE_X,1:MAPSIZE_Y);

    R1 = 25; h1 = 25;
    x1 =228; y1 = 33;

    R0 = 35; h0 =15;
    x0 =88; y0 = 102;

    R2 = 15; h2 = 40;
    x2 =48; y2 = 217;

    R7 = 15; h7 = 25;
    x7 =109; y7 = 168;

    R8 = 15; h8 = 25;
    x8 =283; y8 = 213;


    R5 = 15; h5 = 30;
    x5 =151; y5 =90;


    R13 = 25; h13 = 30;
    x13 =95; y13 = 267;

    R10 = 15; h10 = 30;
    x10 =167; y10 = 267;


    R11 = 20; h11 = 30;
    x11 =227; y11 = 190;

    R12 = 25; h12 = 30;
    x12 =155; y12 = 172;

    
    % Map size
    xmin = 1;
    xmax=MAPSIZE_X;
    ymin= 1;
    ymax= MAPSIZE_Y;
    zmin = 5;
    zmax = 20;  
    start_location = [30 35 15; 32 54 15;32 75 15;13 32 15];   
    end_location = [250 264 15;256 158 15; 234 280 15;277 178 15];


    % Number of waypoints
    n=6;
    
    % Number of UAVs
    num=size(start_location,1);
    
    model.start=start_location;
    model.end=end_location;
    model.n=n;
    model.cons = 7;
    model.num=num;
    model.xmin=xmin;
    model.xmax=xmax;
    model.zmin=zmin;
    model.ymin=ymin;
    model.ymax=ymax;
    model.zmax=zmax;
    model.MAPSIZE_X = MAPSIZE_X;
    model.MAPSIZE_Y = MAPSIZE_Y;
    model.X = X;
    model.Y = Y;
    model.H = H1_smooth / 50;
    model.radars = [x10 y10 R10 h10;x11 y11 R11 h11;x12 y12 R12 h12;x13 y13 R13 h13;x2 y2 R2 h2;x5 y5 R5 h5;x7 y7 R7 h7;x8 y8 R8 h8;x1 y1 R1 h1;x0 y0 R0 h0];
    PlotModel(model,pic);
end