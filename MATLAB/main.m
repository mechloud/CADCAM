 function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 21-Nov-2017 18:25:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Clear the command window
clc

% Add subfunctions path
addpath('Subfunctions');
addpath('Database');

% Set a radio button on by default
set(handles.rb_front,'Value',1);

% Set the window title
set(handles.figure1,'Name','Fluent Design - CADCAM 2017');

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% range_check
% RANGE_CHECK compares the obtained value from GUI to min and max and
% returns a warning if applicable.
function val = range_check(min,max,val)
if val > max
    warning(['Desired value outside of parametrizable range\n',...
                    'Resetting to maxmimum value of %.1f\n'],max);
    val = max;
elseif val < min
    warning(['Desired value outside of parametrizable range\n',...
                    'Resetting to minimum value of %.1f\n'],min);
    val = min;
end

%% BTN_GENERATE does all the work
% --- Executes on button press in BTN_generate.
function BTN_generate_Callback(hObject, eventdata, handles)
% hObject    handle to BTN_generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isempty(handles))
    Wrong_File();
else
    logfname = 'log.txt';
    log_id = fopen(logfname,'w+');
    
    fprintf(log_id,['|--------------------------------------------------------------|\n',...
                    '|--------------------------------------------------------------|\n',...
                    '|                       Inputs to Code                         |\n',...
                    '|--------------------------------------------------------------|\n',...
                    '|--------------------------------------------------------------|\n\n']);
                
    % Get the values from the GUI
    frame_width = get(handles.slider_frame_width,'Value');
    fprintf(log_id,'Frame Width = %.0f mm\n',frame_width);
    
    frame_height = get(handles.slider_frame_height,'Value');
    fprintf(log_id,'Frame Height = %.0f mm\n',frame_height);
    
    wheelbase = get(handles.slider_wheelbase,'Value');
    fprintf(log_id,'Wheelbase = %.0f mm \n',wheelbase);
    
    frame_length = wheelbase + 8*25.4;
    fprintf(log_id,'Frame Length = %.0f mm \n',frame_length);
    
    track_width = get(handles.slider_trackwidth,'Value');
    fprintf(log_id,'Track Width = %.0f mm \n',track_width);
    
    ground_clearance = get(handles.slider_ground_clearance,'Value');
    fprintf(log_id,'Ground Clearance = %.0f mm \n',ground_clearance);
    
    front_omegan = get(handles.slider_front_omegan,'Value');
    fprintf(log_id,'Front Natural Frequency = %.2f Hz\n',front_omegan);
    
    rear_omegan = get(handles.slider_rear_omegan,'Value');
    fprintf(log_id,'Rear Natural Frequency = %.2f Hz\n',rear_omegan);
    
    zeta = get(handles.slider_zeta,'Value');
    fprintf(log_id,'Damping Ratio = %.2f\n',zeta);
    
    steering_ratio = get(handles.slider_steering_ratio,'Value');
    fprintf(log_id,'Steering Ratio = %.1f\n',steering_ratio);
    
    md = get(handles.box_mass_driver,'Value');
    if get(handles.rb_lbs,'Value') == 1
        % if the mass is in lbs, convert to kg
        md = md/2.2;
    end
    
    fprintf(log_id,'Mass of the driver = %.1f kg\n',md);
    
    fprintf(log_id,['\n\n|--------------------------------------------------------------|\n',...
                    '|--------------------------------------------------------------|\n',...
                    '|                        Suspension                            |\n',...
                    '|--------------------------------------------------------------|\n',...
                    '|--------------------------------------------------------------|\n\n']);
    
    % Suspension Codes
%     if get(handles.rb_front,'Value') == 1
%         Suspension('gui',0,'f',front_omegan,zeta,md);
%     elseif get(handles.rb_rear,'Value') == 1
%         Suspension('gui',0,'r',rear_omegan,zeta,md);   
%     end
    
    [fbdia,Ks_f] = Suspension('main',log_id,'f',front_omegan,zeta,md);
    [rbdia,Ks_r] = Suspension('main',log_id,'r',rear_omegan,zeta,md);
    
    
    fprintf(log_id,['\n\n|--------------------------------------------------------------|\n',...
                    '|--------------------------------------------------------------|\n',...
                    '|                          Frame                               |\n',...
                    '|--------------------------------------------------------------|\n',...
                    '|--------------------------------------------------------------|\n\n']);
    
    % Frame Codes
    [POD,PWT] = loop_FEA(log_id,frame_length,frame_height,md);
    
    if get(handles.rb_ANSYS,'Value') == 1
        % Load nodal data
        nodal = load('Database/baja_3D_geometry.mat');
        elements = nodal.elements;
        nodes = update_frame_geometry(nodal.nodes,frame_length,frame_height,frame_width);
        
        % Get all the handles related to the radio buttons
        f_impact = get(handles.rb_front_impact,'Value');
        r_impact = get(handles.rb_rear_impact,'Value');
        s_impact = get(handles.rb_side_impact,'Value');
        rollover = get(handles.rb_rollover,'Value');
        
        % Create a cell array with values of radio buttons and tags
        % (strings)
        files_to_create = {f_impact,'front';
                           r_impact,'rear';
                           s_impact,'side';
                           rollover,'rollover'};
        
        % Loop through this array and create an output file for selected
        % situations
        for k = 1:4
            if files_to_create{k,1} == 1
                tools.create_ANSYS_input(log_id,files_to_create{k,2},nodes,elements,...
                                   POD,PWT,25.4,0.9,md);
            end
        end
    end
    
    fprintf(log_id,['\n\n|--------------------------------------------------------------|\n',...
                    '|--------------------------------------------------------------|\n',...
                    '|                        Steering                              |\n',...
                    '|--------------------------------------------------------------|\n',...
                    '|--------------------------------------------------------------|\n\n']);
    
    % Steering Codes - NEED TO RETURN VALUES TO WRITE IN FILE
    [turning_radius,ackangle,h,odt,idt,ltr,rbl,Pr,N,PD,bore,...
    racklength,ir_d,slotsize,stclength,stcangle,ot_OD,ot_ID,os_ID,os_OD] = steering(log_id,frame_width,track_width,wheelbase,steering_ratio,frame_length,md);
    
    [track_width] = Rollover(log_id,track_width, turning_radius, Ks_f,...
               Ks_r,md,ground_clearance);
    
    % TEMPORARY: Define undefined variables
    SOD = 25.0; % Secondary tubing OD
    SWT = 0.89; % Secondary tubing WT
    
    % Write SolidWorks equations/global variables file
    tools.write_equations(POD,PWT,SOD,SWT,fbdia,rbdia,frame_length,frame_width,...
                          frame_height,track_width,ground_clearance,ackangle,...
                          h,odt,idt,ltr,rbl,Pr,N,PD,bore,racklength,ir_d,...
                          slotsize,stclength,stcangle,ot_OD,ot_ID,os_ID,os_OD);
                      
    % Close the log file
    try
        fclose(log_id);
        fprintf('Successfully wrote log file %s\n',logfname);
    catch
        fprintf('Unable to write log file\n');
    end
end
        

% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close gcf;

% --- Gives out a message that the GUI should not be executed directly from
% the .fig file. The user should run the .m file instead.
function Wrong_File()
clc
h = msgbox('You cannot run the MAIN.fig file directly. Please run the program from the Main.m file directly.','Cannot run the figure...','error','modal');
uiwait(h);
disp('You must run the MAIN.m file. Not the MAIN.fig file.');
disp('To run the MAIN.m file, open it in the editor and press ');
disp('the green "PLAY" button, or press "F5" on the keyboard.');
close gcf

function log_output_Callback(hObject, eventdata, handles)
% hObject    handle to log_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of log_output as text
%        str2double(get(hObject,'String')) returns contents of log_output as a double


% --- Executes during object creation, after setting all properties.
function log_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to log_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_frame_length_Callback(hObject, eventdata, handles)
% hObject    handle to slider_frame_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_frame_length,'String',num2str(round(val,0)));


% --- Executes during object creation, after setting all properties.
function slider_frame_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_frame_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_frame_width_Callback(hObject, eventdata, handles)
% hObject    handle to slider_frame_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_frame_width,'String',num2str(round(val,0)));

% --- Executes during object creation, after setting all properties.
function slider_frame_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_frame_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_frame_height_Callback(hObject, eventdata, handles)
% hObject    handle to slider_frame_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_frame_height,'String',num2str(round(val,0)));

% --- Executes during object creation, after setting all properties.
function slider_frame_height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_frame_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_front_omegan_Callback(hObject, eventdata, handles)
% hObject    handle to slider_front_omegan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_front_omegan,'String',num2str(round(val,2)));
if get(handles.rb_front,'Value') == 1 
    front_omegan = get(handles.slider_front_omegan,'Value');   
    zeta = get(handles.slider_zeta,'Value');
    md = get(handles.box_mass_driver,'Value');
    if get(handles.rb_lbs,'Value') == 1
        % if the mass is in lbs, convert to kg
        md = md/2.2;
    end
    Suspension('gui',0,'f',front_omegan,zeta,md);
end



% --- Executes during object creation, after setting all properties.
function slider_front_omegan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_front_omegan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_rear_omegan_Callback(hObject, eventdata, handles)
% hObject    handle to slider_rear_omegan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_rear_omegan,'String',num2str(round(val,2)));
if get(handles.rb_rear,'Value') == 1     
    front_omegan = get(handles.slider_front_omegan,'Value');
    rear_omegan = get(handles.slider_rear_omegan,'Value');   
    zeta = get(handles.slider_zeta,'Value');
    md = get(handles.box_mass_driver,'Value');
    if get(handles.rb_lbs,'Value') == 1
        % if the mass is in lbs, convert to kg
        md = md/2.2;
    end
    Suspension('gui',0,'r',rear_omegan,zeta,md);
end

% --- Executes during object creation, after setting all properties.
function slider_rear_omegan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_rear_omegan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_zeta_Callback(hObject, eventdata, handles)
% hObject    handle to slider_zeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_zeta,'String',num2str(round(val,2)));

    front_omegan = get(handles.slider_front_omegan,'Value');
    rear_omegan = get(handles.slider_rear_omegan,'Value');   
    zeta = get(handles.slider_zeta,'Value');
    md = get(handles.box_mass_driver,'Value');
    if get(handles.rb_lbs,'Value') == 1
        % if the mass is in lbs, convert to kg
        md = md/2.2;
    end
%%
% Suspension Codes
    if get(handles.rb_front,'Value') == 1
        Suspension('gui',0,'f',front_omegan,zeta,md);
    elseif get(handles.rb_rear,'Value') == 1
        Suspension('gui',0,'r',rear_omegan,zeta,md);
    else
        Suspension('gui',0,'f',front_omegan,zeta,md);
    end

% --- Executes during object creation, after setting all properties.
function slider_zeta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_zeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider_steering_ratio_Callback(hObject, eventdata, handles)
% hObject    handle to slider_steering_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_steering_ratio,'String',num2str(round(val,2)));

% --- Executes during object creation, after setting all properties.
function slider_steering_ratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_steering_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider_wheelbase_Callback(hObject, eventdata, handles)
% hObject    handle to slider_wheelbase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_wheelbase,'String',num2str(round(val,0)));

% --- Executes during object creation, after setting all properties.
function slider_wheelbase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_wheelbase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_trackwidth_Callback(hObject, eventdata, handles)
% hObject    handle to slider_trackwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_trackwidth,'String',num2str(round(val,0)));

% --- Executes during object creation, after setting all properties.
function slider_trackwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_trackwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_ground_clearance_Callback(hObject, eventdata, handles)
% hObject    handle to slider_ground_clearance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.box_ground_clearance,'String',num2str(round(val,0)));

% --- Executes during object creation, after setting all properties.
function slider_ground_clearance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_ground_clearance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% % --- Executes on selection change in output.
% function output_Callback(hObject, eventdata, handles)
% % hObject    handle to output (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns output contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from output
% 
% 
% % --- Executes during object creation, after setting all properties.
% function output_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to output (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: listbox controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end

function box_frame_width_Callback(hObject, eventdata, handles)
% hObject    handle to box_frame_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_frame_width as text
%        str2double(get(hObject,'String')) returns contents of box_frame_width as a double
min = get(hObject,'Min');
max = get(hObject,'Max');
val = str2double(get(hObject,'String'));
val = range_check(min,max,val);
set(handles.slider_frame_width,'Value',round(val,0));

% --- Executes during object creation, after setting all properties.
function box_frame_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_frame_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function box_frame_height_Callback(hObject, eventdata, handles)
% hObject    handle to box_frame_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_frame_height as text
%        str2double(get(hObject,'String')) returns contents of box_frame_height as a double
min = get(hObject,'Min');
max = get(hObject,'Max');
val = str2double(get(hObject,'String'));
val = range_check(min,max,val);
set(handles.slider_frame_height,'Value',round(val,0));

% --- Executes during object creation, after setting all properties.
function box_frame_height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_frame_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_front_omegan_Callback(hObject, eventdata, handles)
% hObject    handle to box_front_omegan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_front_omegan as text
%        str2double(get(hObject,'String')) returns contents of box_front_omegan as a double
min = get(hObject,'Min');
max = get(hObject,'Max');
val = str2double(get(hObject,'String'));
val = range_check(min,max,val);
set(handles.slider_front_omegan,'Value',val);

% --- Executes during object creation, after setting all properties.
function box_front_omegan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_front_omegan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function box_rear_omegan_Callback(hObject, eventdata, handles)
% hObject    handle to box_rear_omegan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_rear_omegan as text
%        str2double(get(hObject,'String')) returns contents of box_rear_omegan as a double
min = get(hObject,'Min');
max = get(hObject,'Max');
val = str2double(get(hObject,'String'));
val = range_check(min,max,val);
set(handles.slider_rear_omegan,'Value',val);

% --- Executes during object creation, after setting all properties.
function box_rear_omegan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_rear_omegan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_zeta_Callback(hObject, eventdata, handles)
% hObject    handle to box_zeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_zeta as text
%        str2double(get(hObject,'String')) returns contents of box_zeta as a double
min = get(hObject,'Min');
max = get(hObject,'Max');
val = str2double(get(hObject,'String'));
val = range_check(min,max,val);
set(handles.slider_zeta,'Value',val);

% --- Executes during object creation, after setting all properties.
function box_zeta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_zeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function box_steering_ratio_Callback(hObject, eventdata, handles)
% hObject    handle to box_steering_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_steering_ratio as text
%        str2double(get(hObject,'String')) returns contents of box_steering_ratio as a double
min = get(hObject,'Min');
max = get(hObject,'Max');
val = str2double(get(hObject,'String'));
val = range_check(min,max,val);
set(handles.slider_steering_ratio,'Value',val);

% --- Executes during object creation, after setting all properties.
function box_steering_ratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_steering_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function box_wheelbase_Callback(hObject, eventdata, handles)
% hObject    handle to box_wheelbase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_wheelbase as text
%        str2double(get(hObject,'String')) returns contents of box_wheelbase as a double
min = get(hObject,'Min');
max = get(hObject,'Max');
val = str2double(get(hObject,'String'));
val = range_check(min,max,val);
set(handles.slider_wheelbase,'Value',val);

% --- Executes during object creation, after setting all properties.
function box_wheelbase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_wheelbase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function box_trackwidth_Callback(hObject, eventdata, handles)
% hObject    handle to box_trackwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_trackwidth as text
%        str2double(get(hObject,'String')) returns contents of box_trackwidth as a double
min = get(hObject,'Min');
max = get(hObject,'Max');
val = str2double(get(hObject,'String'));
val = range_check(min,max,val);
set(handles.slider_trackwidth,'Value',val);

% --- Executes during object creation, after setting all properties.
function box_trackwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_trackwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function box_ground_clearance_Callback(hObject, eventdata, handles)
% hObject    handle to box_ground_clearance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_ground_clearance as text
%        str2double(get(hObject,'String')) returns contents of box_ground_clearance as a double
min = get(hObject,'Min');
max = get(hObject,'Max');
val = str2double(get(hObject,'String'));
val = range_check(min,max,val);
set(handles.slider_ground_clearance,'Value',val);

% --- Executes during object creation, after setting all properties.
function box_ground_clearance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_ground_clearance (see GCBO)
% eventdata  reserved - to be defined inhttps://medium.com/@igor_marques/git-basics-adding-more-changes-to-your-last-commit-1629344cb9a8 a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rb_ANSYS.
function rb_ANSYS_Callback(hObject, eventdata, handles)
% hObject    handle to rb_ANSYS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_ANSYS
if get(hObject,'Value') == 0
    action = 'off';
    set(handles.rb_front_impact,'Value',0);
    set(handles.rb_side_impact,'Value',0);
    set(handles.rb_rear_impact,'Value',0);
    set(handles.rb_rollover,'Value',0);
else
    action = 'on';
end
set(handles.rb_front_impact,'Enable',action);
set(handles.rb_side_impact,'Enable',action);
set(handles.rb_rear_impact,'Enable',action);
set(handles.rb_rollover,'Enable',action);


function box_mass_driver_Callback(hObject, eventdata, handles)
% hObject    handle to box_mass_driver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_mass_driver as text
%        str2double(get(hObject,'String')) returns contents of box_mass_driver as a double

min = get(hObject,'Min');
max = get(hObject,'Max');
    md = str2double(get(handles.box_mass_driver,'String'));
    if get(handles.rb_lbs,'Value') == 1
        % if the mass is in lbs, convert to kg
        md = md/2.2;
    end
    if md > max/2.2
        warning(['Mass of driver exceeds design spec, consider losing weight',...
                 'or getting a smaller driver. Resetting to maximum value',...
                 ' of %.0f lbs'],max);
        md = max;
        set(handles.box_mass_driver,'Value',md);
        set(handles.rb_lbs,'Value',1);
    elseif md < min
        warning(['You should know better than to have negative mass...',...
                 ' Resetting to 175 lbs']);
        md = 175;
        set(handles.box_mass_driver,'Value',md);
        set(handles.rb_lbs,'Value',1);
    end


% --- Executes during object creation, after setting all properties.
function box_mass_driver_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_mass_driver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rb_lbs.
function rb_lbs_Callback(hObject, eventdata, handles)
% hObject    handle to rb_lbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_lbs
val = get(hObject,'Value');
if val == 1
    set(handles.rb_kg,'Value',0);
end


% --- Executes on button press in rb_kg.
function rb_kg_Callback(hObject, eventdata, handles)
% hObject    handle to rb_kg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_kg
val = get(hObject,'Value');
if val == 1
    set(handles.rb_lbs,'Value',0);
end


% --- Executes on button press in rb_front.
function rb_front_Callback(hObject, eventdata, handles)
% hObject    handle to rb_front (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_front
val = get(hObject,'Value');
if val == 1
    set(handles.rb_rear,'Value',0);
end

front_omegan = get(handles.slider_front_omegan,'Value');
zeta = get(handles.slider_zeta,'Value');
md = get(handles.box_mass_driver,'Value');
if get(handles.rb_lbs,'Value') == 1
    % if the mass is in lbs, convert to kg
    md = md/2.2;
end
%%
% Suspension Codes
Suspension('gui',0,'f',front_omegan,zeta,md);
   

% --- Executes on button press in rb_rear.
function rb_rear_Callback(hObject, eventdata, handles)
% hObject    handle to rb_rear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_rear
val = get(hObject,'Value');
if val == 1
    set(handles.rb_front,'Value',0);
end

rear_omegan = get(handles.slider_rear_omegan,'Value');
zeta = get(handles.slider_zeta,'Value');
md = get(handles.box_mass_driver,'Value');
if get(handles.rb_lbs,'Value') == 1
    % if the mass is in lbs, convert to kg
    md = md/2.2;
end
%%
% Suspension Codes
Suspension('gui',0,'r',rear_omegan,zeta,md);


% --- Executes on button press in rb_front_impact.
function rb_front_impact_Callback(hObject, eventdata, handles)
% hObject    handle to rb_front_impact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_front_impact


% --- Executes on button press in rb_side_impact.
function rb_side_impact_Callback(hObject, eventdata, handles)
% hObject    handle to rb_side_impact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_side_impact


% --- Executes on button press in rb_rear_impact.
function rb_rear_impact_Callback(hObject, eventdata, handles)
% hObject    handle to rb_rear_impact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_rear_impact


% --- Executes on button press in rb_rollover.
function rb_rollover_Callback(hObject, eventdata, handles)
% hObject    handle to rb_rollover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_rollover
