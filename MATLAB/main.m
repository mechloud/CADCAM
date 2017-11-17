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

% Last Modified by GUIDE v2.5 17-Nov-2017 16:21:34

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

%% BTN_GENERATE does all the work
% --- Executes on button press in BTN_generate.
function BTN_generate_Callback(hObject, eventdata, handles)
% hObject    handle to BTN_generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isempty(handles))
    Wrong_File();
else
    % Get the values from the GUI
    frame_width = get(handles.slider_frame_width,'Value')
    frame_height = get(handles.slider_frame_height,'Value')
    wheelbase = get(handles.slider_wheelbase,'Value')
    frame_length = wheelbase + 8*25.4
    track_width = get(handles.slider_trackwidth,'Value')
    ground_clearance = get(handles.slider_ground_clearance,'Value')
    front_omegan = get(handles.slider_front_omegan,'Value')
    rear_omegan = get(handles.slider_rear_omegan,'Value')
    zeta = get(handles.slider_zeta,'Value')
    steering_ratio = get(handles.slider_steering_ratio,'Value')
    
    %%
    % Suspension Codes
    Suspension('f',front_omegan,zeta,110);
    Suspension('r',rear_omegan,zeta,110);
    
    %%
    % Frame Codes
    [OD,WT] = loop_FEA(frame_length,frame_height);
    if get(handles.rb_ANSYS,'Value') == 1
        % WAITING FOR 3D FEA Excel Spreadsheet (LIZ)
        % Load nodal data
        %nodal = load('2dfea.mat');
        %nodes = nodal.nodes;
        %elements = nodal.elements;
        %create_ANSYS_input(nodes,elements,OD,WT,25.4,0.9);
    end
    
    %%
    % Steering Codes
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


% --- Executes on selection change in output.
function output_Callback(hObject, eventdata, handles)
% hObject    handle to output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns output contents as cell array
%        contents{get(hObject,'Value')} returns selected item from output


% --- Executes during object creation, after setting all properties.
function output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function box_frame_length_Callback(hObject, eventdata, handles)
% hObject    handle to box_frame_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_frame_length as text
%        str2double(get(hObject,'String')) returns contents of box_frame_length as a double
val = str2double(get(hObject,'String'));
set(handles.slider_frame_length,'Value',round(val,0));

% --- Executes during object creation, after setting all properties.
function box_frame_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_frame_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_frame_width_Callback(hObject, eventdata, handles)
% hObject    handle to box_frame_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_frame_width as text
%        str2double(get(hObject,'String')) returns contents of box_frame_width as a double
val = str2double(get(hObject,'String'));
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
val = str2double(get(hObject,'String'));
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
val = str2double(get(hObject,'String'));
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
val = str2double(get(hObject,'String'));
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
val = str2double(get(hObject,'String'));
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
val = str2double(get(hObject,'String'));
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
val = str2double(get(hObject,'String'));
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
val = str2double(get(hObject,'String'));
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
val = str2double(get(hObject,'String'));
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
