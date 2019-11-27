function varargout = untitled3(varargin)


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled3_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled3_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
 
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function untitled3_OpeningFcn(hObject, eventdata, handles, varargin)
 
set(handles.axes1,'xtick',[],'ytick',[])
set(handles.axes7,'xtick',[],'ytick',[])
set(handles.axes8,'xtick',[],'ytick',[])
set(handles.axes5,'xtick',[],'ytick',[])
set(handles.axes9,'xtick',[],'ytick',[])



handles.output = hObject;
 

guidata(hObject, handles);
 
 
 

function varargout = untitled3_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
 
 


function FrameDif_Callback(hObject, eventdata, handles)


input_video=VideoReader(get(handles.text2,'String'));

frameSayisi=get(handles.frameSayisi,'String');
N=str2num(frameSayisi);

[m,n]= size(input_video);
sum_bg=zeros(m,n);

for i=1:N;
input_frm = read(input_video,i);
background=double(rgb2gray(input_frm));
sum_bg=sum_bg+background;
 
end
mean_bg=sum_bg/N;

C=3;

image=read(input_video,1);
img_gray = rgb2gray(image); % convert to greyscale
[width, height] = size(img_gray);
pixel_depth = 8;
pixel_range = 2^pixel_depth - 1;
mean = rand([width, height, C])*pixel_range;    % pixel means
w = ones([width, height, C]) * 1/C;             % initialize weights array
sd_init = 0.001;    % initial standard deviation (for new components)
sd = ones([width, height, C]) * sd_init; 

[rows, columns, numberOfColorChannels] = size(image);


buffer=zeros(N,rows,columns);
 
 
  for k=1:N 
        input_frm  = read(input_video,k);
         background=double(rgb2gray(input_frm));
         buffer(k,:,:)=background;

        
  end
     
median_bg=zeros(rows,columns);
for i=1:rows 
 for j=1:columns 
     median_bg(i,j)=median(buffer(:,i,j));
     
 end
end

      
for i=2:input_video.NumberOfFrames;
    
    thresh2=get(handles.slider4,'Value');
    thresh=thresh2*200;
    set(handles.edit2,'String',num2str(thresh));
    
    
 fr = read(input_video,i);
 fr_bw=double(rgb2gray(fr));
 
 bg=read(input_video,i-1);
 bg_bw=double(rgb2gray(bg));
 
  fr_diff = abs(fr_bw - bg_bw); 
 foreground_image=fr_diff > thresh;
 
frame_diff = abs(fr_bw - mean_bg); 
foreground_image2=frame_diff > thresh;

 frame_diff2 = abs(fr_bw - median_bg);
 foreground_image3=frame_diff2 > thresh;

  
   D = 2.5;        % positive deviation threshold
   alpha = 0.01;   % learning rate (between 0 and 1)
   sd_init = 0.001;    % initial standard deviation (for new components)

    % calculate difference of pixel values from mean

    img_gray_dim3 = cat(3, fr_bw, fr_bw, fr_bw);
    u_diff = img_gray_dim3 - mean;
    
    % update gaussian components for each pixel
    indices_to_update = u_diff<=D*sd;
    % update weights
    w = (1 - alpha) * w;
    w(indices_to_update) = w(indices_to_update) + alpha;
    % update means and standard deviations for each gaussian distribution
    p = alpha./w;
    mean_new = (1-p).*mean + p.*img_gray_dim3;
    sd_new = sqrt((1-p).*sd.^2) + p.*(img_gray_dim3-mean).^2;
    mean(indices_to_update) = mean_new(indices_to_update);
    sd(indices_to_update) = sd_new(indices_to_update);
    % calculate background model
    w = w ./ cat(3, sum(w,3),sum(w,3),sum(w,3));
    gmm_back_ground = sum(mean .* w, 3);
    
    % if no components match, create new component
    match = any(indices_to_update, 3);

    [width, height] = size(fr_bw);
    for i = 1:width
        for j = 1:height
            % if no components match, create new component
            if (match(i,j) == 0)
                [~, w_index] = min(w(i,j,:));
                mean(i,j,w_index) = fr_bw(i,j);
                sd(i,j,w_index) = sd_init;
            end
        end
    end
    


    foreground_image4 = abs(fr_bw - gmm_back_ground);
    foreground_image4(foreground_image4 < thresh) = 0;
    gmm_back_ground = uint8(gmm_back_ground);
    foreground_image4 = logical(foreground_image4);
    

 
axes(handles.axes1);
imshow((fr),[]);
title('Orginal Video');
drawnow;

axes(handles.axes7);
imshow((foreground_image),[]);
title('Frame Difference');
drawnow;

axes(handles.axes8);
imshow((foreground_image2),[]);
title('Mean Filter');
drawnow;

axes(handles.axes5);
imshow((foreground_image3),[]);
title('Median Filter');
drawnow;
 
axes(handles.axes9);
imshow((foreground_image4),[]);
title('GMM Video');
drawnow;


% 
% t = 0: 0.01 : 10;
% % Grafiðin y eksenini oluþturacak u(t) sinyalinin tanýmlanmasý
%  u = 2*sin(t);
% % Grafiðin çizdirilmesi
%  plot(t,u)
  
end

 


 

function pushbutton5_Callback(hObject, eventdata, handles)

if(strcmp(get(handles.pushbutton5,'String'),'Pause'))
    set(handles.pushbutton5,'String','Play');
      uiwait();

else

    set(handles.pushbutton5,'String','Pause');
             uiresume();

end

 
function sec_Callback(hObject, eventdata, handles)

[file path] = uigetfile('*.avi; *.mp4; *.wmv','Select video files');
chosenfile = [path file];
dosyaIsmi=strcat(path,'',file);
set(handles.text2,'String',dosyaIsmi);



function frameSayisi_Callback(hObject, eventdata, handles)



function frameSayisi_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider4_Callback(hObject, eventdata, handles)




function slider4_CreateFcn(hObject, eventdata, handles)


if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit2_Callback(hObject, eventdata, handles)


function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% function edit3_Callback(hObject, eventdata, handles)
% 
% 
% function edit3_CreateFcn(hObject, eventdata, handles)
% 
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% end
