function [hcomponent,jcomp] = uicomponent(varargin)
%UICOMPONENT an enhanced replacement for UICONTROL & JAVACOMPONENT, accepting all Java Swing/AWT style components
%
%   hcomponent = UICOMPONENT('PropertyName1',value1,'PropertyName2',value2,...) 
%   creates a user interface control in the current figure window and returns
%   a handle to it. It assigns the default values to any properties you do not
%   specify. The default style, like in UICONTROL, is a pushbutton. 
%
%   UICOMPONENT(parent,...) creates a control in the specified parent handle
%   (figure, frame, uipanel, uicontainer, uiflowcontainer or uigridcontainer).
%   This is equivalent to UICOMPONENT('Parent',parent,...).
%   Note the extension to JAVACOMPONENT, which only accepts figure parents.
%   Actually, (due to internal Matlab limitations) the component is always
%   created as a child of the figure - the parent is used as a reference
%   location for the component's position (relative to the parent).
%
%   UICOMPONENT(javacomponent,...) uses the pre-existing javacomponent, and
%   just places it on-screen and returns a single handle.
%
%   UICOMPONENT properties can be set at object creation time using
%   PropertyName/PropertyValue pair arguments to UICOMPONENT, or 
%   changed later using the SET command or handle.prop=value notation.
%
%   Execute GET(H) to see a list of UICOMPONENT object properties and
%   their current values. Execute SET(H) to see a list of UICOMPONENT
%   object properties and legal property values. See the
%   <a href="matlab:doc uicontrol_props">Uicontrol Properties reference page</a> for more information.
%
%   UICOMPONENT(H) gives focus to the component specified by the handle H.
%   This enables keyboard actions on the selected component, in addition
%   to the regular mouse actions.
%
%   UICOMPONENT is intended as a direct replacement of Matlab's builtin
%   UICONTROL and JAVACOMPONENT functions. It accepts all parameters and
%   styles that UICONTROL accepts, and in addition also any other presentable 
%   <a href="http://java.sun.com/j2se/1.4.2/docs/api/java/awt/Component.html">Java Swing/AWT component</a>.
%   The calling convention and syntax of UICONTROL were preserved for full
%   backwards compatibility.
%
%   UICOMPONENT('Style',style,{optionalConstructorArgs},...) uses the
%   requested style, which includes all of UICONTROL's styles as well as
%   any java component (see below). Optional java constructor args may be
%   passed to the style upon creation - multiple args as well as a string
%   arg should be placed in a cell-array, in order to differentiate them
%   from the following PropertyName. In most cases, properties may be 
%   modified post-creation, and need not be passed to the constructor.
%
%   UICONTROL's accepted 'Style' values (case insensitive):
%      'pushbutton','togglebutton','radiobutton','checkbox','edit'
%      'text','slider','frame','listbox','popupmenu'
%
%   UICOMPONENT's additional accepted 'Style' values (partial list):
%      1) <a href="http://java.sun.com/j2se/1.4.2/docs/api/java/awt/package-summary.html">java.awt.*</a> objects:
%         'scrollbar','textcomponent','textarea','textfield','label',
%         'list','choice','canvas','container','button','panel',
%         'scrollpane','window','dialog','frame','filedialog'
%      2) <a href="http://java.sun.com/j2se/1.4.2/docs/api/javax/swing/package-summary.html">javax.swing.*</a> objects:
%         'CellRendererPane','JComponent','JApplet','JWindow','JDialog',
%         'AbstractButton','BasicInternalFrameTitlePane','Box','Box.Filler',
%         'JColorChooser','JComboBox','JFileChooser','JInternalFrame',
%         'JInternalFrame.JDesktopIcon','JLabel','JLayeredPane','JList',
%         'JMenuBar','JOptionPane','JPanel','JPopupMenu','JProgressBar',
%         'JRootPane','JScrollBar','JScrollPane','JScrollPane.ScrollBar',
%         'JSeparator','JSlider','JSpinner','JSplitPane','JTabbedPane',
%         'JTable','JTableHeader','JTextComponent','JToolBar','JToolTip',
%         'JTree','JViewport','JButton','JToggleButton','JMenuItem',
%         'JCheckBoxMenuItem','JMenu','JRadioButtonMenuItem','JCheckBox',
%         'JRadioButton','JDesktopPane','JPopupMenu.Separator','JToolBar.Separator',
%         'JEditorPane','JTextArea','JTextField','JTextPane',
%         'JFormattedTextField','JPasswordField'
%      3) Any fully-qualified class name: 'javax.swing.JSlider','com.mywork.MyClass'...
%
%   Examples:
%      Example 1: (uses regular UICONTROL)
%           %creates uicontrol specified in a new figure
%           uicomponent('Style','edit','String','hello'); 
%     
%      Example 2: (uses regular UICONTROL)
%           %creates three figures and only puts uicontrol in the second figure
%           fig1 = figure;
%           fig2 = figure;
%           fig3 = figure;
%           uicomponent('Parent', fig2, 'Style', 'edit','String','hello');
%
%      More Examples: (uses UICOMPONENT's additional styles):
%           uicomponent('style','jspinner','value',7);  % simple spinner with initial value
%           uicomponent('style','javax.swing.jslider','tag','myObj');  % simple horizontal slider
%           uicomponent('style','slider', 'position',[50,50,60,150], 'value',70, ...
%                       'MajorTickSpacing',20, 'MinorTickSpacing',5, ...
%                       'Paintlabels',1,'PaintTicks',1, 'Orientation',1);  % vertical slider
%
%           h=uicomponent('style','JComboBox',{1,pi,'text'},'editable',true); % editable drop-down
%           h.javaComponent.addItem('text2');  % adding data to the drop-down post-creation
%           h.ActionPerformedCallback = @myMatlabFunction;  % setting a callback
%           uicomponent(h);  % sets the focus to component h (enabled keyboard actions)
%           string = h.JavaComponent.getSelectedItem;  % get the currently selected item
%           string = get(h,'selecteditem');  % equivalent way to do the same thing
%           string = h.sElEcTeDiTeM;  % ...a 3rd way to do the same (note case insensitivity)
%
%   Callbacks:
%     Over 30 callback hooks are exposed to the user (the exact list depends on the selected
%     style). These callbacks include mouse movement/clicks, keyboard events, focus gain/loss,
%     data changes etc. In most cases, the user would be concerned mainly with the
%     'StateChangedCallback', which is triggered whenever some property of the component has
%     changed (position, value etc.). In some cases, 'StateChangedCallback' is unavailable
%     and the user should use alternative callbacks, like 'ActionPerformedCallback'. Type
%     'set(hcomponent)' for the full list of callbacks supported by your specific hcomponent.
%
%   Programming tips:
%     1) Unless UICONTROL is used, the returned hcomponent contains 2 useful properties:
%        - JavaComponent - a reference to the created java component.
%        - MatlabHGContainer - the numeric handle h to the Matlab HG container. This is the
%          value returned by the findall/finobj matlab functions. You can still get/set all the
%          component properties using this numeric handle, but they'd be hidden unless you use
%          handle(h) or hcomponent, which is the same thing.
%     2) JAVACOMPONENT normally sets the container's UserData property to the classname of the
%        component (a string). This UICOMPONENT sets UserData to a reference to hcomponent, to
%        make it easy for novice users to see all properties without using handle().
%     3) The user is referred to <a href="http://java.sun.com/docs/books/tutorial/uiswing/index.html">Sun's official Swing Tutorial</a>
%
%   Warning:
%     This code heavily relies on undocumented and unsupported Matlab functionality.
%     It works on Matlab 7+, but use at your own risk!
%
%   Bugs and suggestions:
%     Please send to Yair Altman (altmany at gmail dot com)
%
%   Change log:
%     2007-Apr-10: First version posted on MathWorks file exchange: <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=14583">http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=14583</a>
%     2007-Apr-12: Set large initial size for *Chooser classes; fixed Window subclasses issue; fixed help comment; enabled non-figure parent; enabled non-cell ctorArgs; set default Tag prop
%     2007-May-18: Handle pre-existing java components
%     2007-Jul-19: Handle shortened property names per suggestion by H. Marx
%     2014-Oct-10: Fixed for R2014b (HG2)
%     2014-Oct-20: Fixed a bug in setting the JavaComponent field
%     2015-Nov-02: Added tabs and panels as acceptable parent containers per suggestion by Amir G.
%     2016-Mar-30: Added support for all HG2 containers (inc. uiextras) as parents per suggestion by D. Sampson
%
%   See also:
%     uicontrol, javacomponent, java, set, get, FINDJOBJ (on the <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=14317">file exchange</a>)

% License to use and modify this code is granted freely without warranty to all, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.7 $  $Date: 2016/03/30 17:36:32 $

    % First, try to use uicontrol directly
    try
        hcomp = uicontrol(varargin{:});
    catch
        % Ensure that javacomponent is supported on this platform...
        error(javachk('awt'));
        %if ~usejavacomponent, error('YMA:uicomponent:Unsupported','UICOMPONENT is not supported on this platform'); end

        % Check for focus-request
        if nargin==1
            try
                % Request the focus for the supplied component's java peer
                hcomp = varargin{1};
                hcomp.JavaComponent.requestFocus;

                % Succeeded, so exit
                hcomponent = hcomp;
                return;
            catch
                error('YMA:uicomponent:IllegalComponent','In uicomponent(h), h must be a handle returned by uicomponent or uicontrol');
            end
        end

        % Parse argnames/values
        [parent,pvPairs] = parseparams(varargin);

        % Check for pre-existing javaComp
        isJavaObj = ~isempty(parent) && isjava(parent{1}(1));
        if isJavaObj
            javaComp = parent{1}(1);
            parent = [];
        end

        % Get the requested component style, position & parent
        [pvPairs,style,ctorArgs]  = getStyle   (pvPairs);
        [pvPairs,position]        = getPosition(pvPairs,style);
        [pvPairs,position,parent] = getParent  (pvPairs,position,parent);

        % Try to create the java component (if not pre-existing)
        if ~isJavaObj
            try
                % Note: feval is WAY faster than awtinvoke, so use feval whenever possible
                %javaComp = awtcreate(style);
                javaComp = feval(style,ctorArgs{:});
            catch
                % Maybe user didn't enclose ctorArgs with {}...
                javaComp = feval(style,ctorArgs);
            end
        end

        % Place the new component on-screen (invisible until we finish processing - prevents animation)
        if ~isa(javaComp,'java.awt.Window')
            [jcomp, hcontainer] = javacomponent(javaComp,position,parent);
        else
            % Workaround for javacomponent's bug with java.awt.Window and sub-classes...
            [jcomp, hcontainer] = javacomponentFix(javaComp,position,parent);
        end
        set(hcontainer,'Visible','off');

        % Note: Use the undocumented handle() to get the handle of the component's Matlab container
        % ^^^^  This is needed in order to add all of the java component's properties, below
        hcomp = handle(hcontainer);

        % Move all the container's properties to the component
        try curUndoc = get(0,'hideundocumented'); set(0,'hideundocumented','off'); catch, end  % no-go on HG2...
        % Note: sometimes dataStruct does NOT contain all java values, so a very short pause is needed
        %pause(0.003);  % not needed now that we use localGetData
        dataStruct = get(jcomp);
        try set(0,'hideundocumented',curUndoc); catch, end  % no-go on HG2...
        fieldNames = fieldnames(dataStruct);
        for fieldIdx = 1 : length(fieldNames)

            % Add this container field to the component
            thisFieldName = fieldNames{fieldIdx};
            try
                jsp = findprop(jcomp,thisFieldName);
                try
                    % HG1 - R2014a or earlier
                    msp = schema.prop(hcomp,thisFieldName,'mxArray');  %jsp.DataType

                    % Note: sometimes dataStruct still does NOT contain all java values, so get them directly
                    % Note2: unused for now: we use localGetData instead
                    %{
                    if isempty(dataStruct.(thisFieldName)) && isempty(strfind(thisFieldName,'Callback'))
                        if ~isequal(dataStruct.(thisFieldName),get(jcomp,thisFieldName))
                            pause(0.001);  %should usually suffice
                            %disp(thisFieldName);
                            dataStruct.(thisFieldName) = get(jcomp,thisFieldName);
                        end
                    end
                    set(hcomp,thisFieldName,dataStruct.(thisFieldName));
                    %}

                    % Set the public accessability flags like in the Java original
                    msp.AccessFlags.PublicGet = jsp.AccessFlags.PublicGet;
                    msp.AccessFlags.PublicSet = jsp.AccessFlags.PublicSet;
                    msp.GetFunction = {@localGetData,jcomp,thisFieldName};
                    msp.SetFunction = {@localSetData,jcomp,thisFieldName};
                    msp.Visible = jsp.Visible;
                catch
                    % HG2 - R2014b or newer
                    msp = addprop(hcomp,thisFieldName);
                    if ~jsp.AccessFlags.PublicGet,  msp.GetAccess = 'private';  end
                    if ~jsp.AccessFlags.PublicSet,  msp.SetAccess = 'private';  end
                    msp.GetMethod = @(h)  localGetData(h,[],jcomp,thisFieldName);
                    msp.SetMethod = @(h,v)localSetData(h,v, jcomp,thisFieldName);
                    if strcmpi(jsp.Visible,'off'),  msp.Hidden = true;  end
                end
            catch
                % Never mind: property probably already exists...
                %disp([thisFieldName ': ' lasterr]);
            end

            % Link the new props between the two handles
            % Note: unused for now: we use localGet/SetData instead
            %{
            try
                % Note: can't use linkprop since jcomp goes out of scope soon and linkprop then deletes all linkages...
                linkprops([hcomp,jcomp],thisFieldName);
            catch
                % Never mind: probably cannot modify this prop
            end
            %}
        end

        % Synchronize all props upon state change
        % Note: unused for now: we use localGet/SetData instead
        %setupChangeCallback(hcomp,jcomp);

        % Store the container & component's handles in the component
        storeHandles(hcomp,jcomp,hcontainer);

        % Process the remainder of the user-supplied args (PV-pairs)
        if ~isempty(pvPairs)
            try
                set(hcomp,pvPairs{:});
            catch
                set(jcomp,pvPairs{:});  % HG2 - should not be needed!!! all java props should be in hcomp!
            end
        end

        % Display the component on-screen, unless user requested a specific visibility
        visIdx = find(strncmpi(pvPairs,'vis',3), 1);
        if isempty(visIdx)
            set(hcomp,'Visible','on');
        end
        if isa(javaComp,'java.awt.Window') && strcmpi(hcomp.Visible,'on')
            jcomp.validate();
            jcomp.show();
        end
    end

    % Refresh the screen
    drawnow;

    % Return the component handle, if requested
    if nargout
        hcomponent = hcomp;
    end
end

%% Get the java class from the classname (case-insensitive)
function javaClass = getJavaClass(className)
    % First get the class-loader fired-up
    try
        jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
    catch
        error('YMA:uicomponent:ClassLoaderNotFound', 'Failed to get a valid Java ClassLoader');
    end

    % First try finding the class without any changes in java.awt or javax.swing
    javaClass = findAwtSwingClass(jloader, className);

    % If unfound, try fixing the className's case and retry
    if isempty(javaClass)
        javaClass = findAwtSwingClass(jloader, fixClassNameCase(className));
    end
end

%% Try to find stripped-down class in java.awt.* or javax.swing.*
function javaClass = findAwtSwingClass(jloader, className)
    % First try using the classname as-is as a first attempt
    try
        javaClass = char(jloader.findClass(className).getCanonicalName);
        % succeeded!
    catch
        % failed - name might be a stripped-down class name - try javax.swing...
        try
            javaClass = char(jloader.findClass(['javax.swing.' className]).getCanonicalName);
        catch
            % failed - try java.awt...
            try
                javaClass = char(jloader.findClass(['java.awt.' className]).getCanonicalName);
            catch
                % failed - try javax.swing.J*...
                try
                    javaClass = char(jloader.findClass(['javax.swing.J' className]).getCanonicalName);
                catch
                    javaClass = [];
                end
            end
        end
    end
end

%% Try to fix a className's case to the format used by Sun
function className = fixClassNameCase(className)
    % First lowercase everything
    className = lower(className);

    % First char is always UPPER, except if part of a package name
    if length(strfind(className,'.')) < 2
        className(1) = upper(className(1));

        % Second char is UPPER if first char == 'J'
        if className(1)=='J'
            className(2) = upper(className(2));
        end
    end

    % First char following '.' is always UPPER
    dotIdx = strfind(className,'.');
    for charIdx = 1 : length(dotIdx)
        thisIdx = dotIdx(charIdx);
        thisToken = className(thisIdx:end);
        if ~strncmp(thisToken,'.swing',6) && ~strncmp(thisToken,'.awt',4)
            className(thisIdx+1) = upper(className(thisIdx+1));
        end

        % Second char is UPPER if first char == 'J'
        if className(thisIdx+1)=='J'
            className(thisIdx+2) = upper(className(thisIdx+2));
        end
    end

    % Finally, some keywords always start with UPPER
    tokenWords = '(bar|component|area|field|pane|dialog|renderer|button|internal|frame|title|box|chooser|icon|menu|header|tip|item|)';
    className = regexprep(className,tokenWords,'${[upper($1(1)) $1(2:end)]}');
end

%% Get the requested component style
function [pvPairs,style,ctorArgs] = getStyle(pvPairs)
    % Get the requested component Style
    styleIdx = find(strcmpi(pvPairs,'style'));
    style = 'javax.swing.JButton';  % Default style is a JButton
    ctorArgs = {};
    if any(styleIdx) && styleIdx(end) < length(pvPairs)
        style = pvPairs{styleIdx(end)+1};
        if ~ischar(style)
            error('YMA:uicomponent:InvalidStyle','Invalid component style specified - must be a string');
        end

        % Get the fully-qualified (canonical) class name for the given Style, if found
        newStyle = getJavaClass(style);

        % If not found, raise error
        if isempty(newStyle)
            error('YMA:uicomponent:ClassNotFound', ['Failed to find Java class ''' style '''.']);
        end

        % Search for optional ctorArgs
        while (styleIdx(end)+2 <= length(pvPairs)) && ~ischar(pvPairs{styleIdx(end)+2})
            ctorArgs = [ctorArgs pvPairs{styleIdx(end)+2}]; %#ok<AGROW>
            pvPairs(styleIdx(end)+2) = [];
        end

        style = newStyle;
        pvPairs([styleIdx,styleIdx+1]) = [];
    end
end

%% Get the requested component position
function [pvPairs,position] = getPosition(pvPairs,style)
    position = [];  % default position set by javacomponent to [20,20,60,20]
    if ~isempty(strfind(lower(style),'chooser'))
        position = [0,0,400,250];  % JFileChooser & JColorChooser need a large initial size
        % TODO: use getMinimumSize
    end
    positionIdx = find(strncmpi(pvPairs,'pos',3));
    if any(positionIdx) && positionIdx(end) < length(pvPairs)
        position = pvPairs{positionIdx(end)+1};
        if ~isnumeric(position)
            error('YMA:uicomponent:InvalidPosition','Invalid component position specified - must be a 4-element numeric position vector');
        end
        pvPairs([positionIdx,positionIdx+1]) = [];
    end
end

%% Get the requested component parent
function [pvPairs,position,parent] = getParent(pvPairs,position,parent)
    % Default parent is the current figure (create new figure if none is open)
    if isempty(parent) || ~ishandle(parent{1}(1))
        curVis = get(0,'showHiddenHandles');
        set(0,'showHiddenHandles','on');
        parent = gcf;
        set(0,'showHiddenHandles',curVis);
    else
        parent = parent{1};
        if length(parent)>1
            warning('YMA:uicomponent:TooManyParents','UICOMPONENT accepts only a single parent container - only first is used');
            parent = parent(1);
        end
    end

    % Check if a container parent is specified in the PV pairs - use the last one if possible
    parentIdx = find(strcmpi(pvPairs,'parent'));
    if any(parentIdx) && parentIdx(end) < length(pvPairs)
        parent = pvPairs{parentIdx(end)+1};
        pvPairs([parentIdx,parentIdx+1]) = [];
    end

    % Only figures are currently supported by JAVACOMPONENT as valid parents...
    hParent = handle(parent);
    if ~ishghandle(parent)
        parentStr = '';
        try
            if isnumeric(parent)
                parentStr = num2str(parent);
            else
                parentStr = char(parent);
            end
        catch
        end
        error('YMA:uicomponent:InvalidParentHandle',['Invalid parent handle specified: ' parentStr]);
    %elseif ~(isa(hParent,'figure') || isa(hParent,'uicontainer') || isa(hParent,'uiflowcontainer') || isa(hParent,'uigridcontainer'))
    elseif ~any(strcmpi(regexprep(class(hParent),'.*\.',''),{'figure','uicontainer','uiflowcontainer','uigridcontainer','uipanel','panel','tab','uitab'})) && ~isa(hParent,'matlab.ui.container.Container')
        % We get here for all parents not accepted by JAVACOMPONENT as valid parents - try a workaround
        %error('YMA:uicomponent:InvalidParentType','Invalid parent container specified - only figure/panel handles are accepted');
        warning('YMA:uicomponent:NonFigureParent','Non-figure parent was specified - using the parent''s figure as the component''s parent\n(Type "<a href="matlab:warning off YMA:uicomponent:NonFigureParent">warning off YMA:uicomponent:NonFigureParent</a>" to suppress this warning.)');
        parentPosition = getpixelposition(parent,true);
        if isempty(position)
            position = [20,20,60,20];  % default position = bottom-left corner of parent
        end
        position = position + [parentPosition(1:2),0,0];  % pixel position relative to figure
        parent = ancestor(parent,'figure');
    end
end

%% Link property fields
function linkprops(handles,propName)
    msp = findprop(handles(1),propName);
    msp.GetFunction = {@localGetData,handles(2),propName};
    msp.SetFunction = {@localSetData,handles(2),propName};

    % This is a slower method no longer in use
    %{
    propertyListeners___ = getappdata(handles(1),'propertyListeners___');
    if isempty(propertyListeners___)
        propertyListeners___ = handle([]);
    end

    % Listener to property changes
    for hIdx = 1 : length(handles)
        prop = findprop(handles(hIdx),propName);
        if ~isempty(prop)
            listenerIdx = length(propertyListeners___) + 1;
            propertyListeners___(listenerIdx) = handle.listener(handles(hIdx),prop,'PropertyPostSet',{@localUpdateProp,handles,listenerIdx});
        else
            % never mind...
            disp(['Problematic property: ' propName]);
        end
    end
    setappdata(handles(1),'propertyListeners___',propertyListeners___);
    %}
end

%% Property update function
function localUpdateProp(eventsrc,eventdata,handles,listenerIdx)  %#ok
    try
        % Determine which is the original & target handles
        hSrc = eventdata.AffectedObject;
        if isequal(hSrc,handles(1))
            % hcomp was modified
            hDst = handles(2);  % =jcomp
            peerIdx = 1;
        else
            % jcomp was modified
            hDst = handles(1);  % =hcomp
            peerIdx = -1;
        end

        % Exit if handles are already synchronized for this property
        propName = eventsrc.Name;
        if isEqual(eventdata.NewValue,get(hDst,propName))
            return;
        end

        % Temporarily turn off listener for this property to avoid endless loop
        propertyListeners___ = getappdata(handles(1),'propertyListeners___');
        hListener = propertyListeners___(listenerIdx+peerIdx);
        set(hListener,'Enabled','off');

        % Update all linked objects that have this property
        %try
        %    newValStr = eventdata.NewValue;
        %    newValStr = num2str(newValStr);
        %catch
        %    newValStr = char(newValStr.toString);
        %end
        %disp([hDst.class ' ' propName ' => ' newValStr]);
        if isprop(hDst,propName)
            set(hDst,propName,eventdata.NewValue);
        end

        % Ensure that all props are stil in sync between the handles
        % Note: this is needed since the new value may have triggered other changes in the target handle
        if ~isprop(handles(1),'StateChangedCallback') || isempty(get(handles(1),'StateChangedCallback'))
            % ...But only do this if the state-changed callback (that takes care of this) is not available
            syncProps([],[],handles(2),handles(1));
        end

        % Restore listeners
        set(hListener,'Enabled','on');
    catch
        %disp(lasterr);  % Never mind...
    end
end

%% Check for data equality
function equalsFlag = isEqual(srcValue,dstValue)
    % Use matlab's generic isequal() method first
    equalsFlag = isequal(srcValue,dstValue);
    try
        if ~equalsFlag
            % Many java objects have applicative equals(), so use it whenever possible
            % This way, even if the reference changed it may still be considered "equal"
            equalsFlag = srcValue.equals(dstValue);
        end
    catch
        % never mind - no equals() method available in this case
    end
end

%% Synchronize java component & Matlab HG container properties
function syncProps(eventsrc,eventdata,hSrc,hDst)  %#ok

    % Init
    srcData = get(hSrc);
    dstData = get(hDst);
    fieldNames = intersect(fieldnames(srcData),fieldnames(dstData));

    % Loop over all fields and check for unsynchronized values
    for fieldIdx = 1 : length(fieldNames)
        thisFieldName = fieldNames{fieldIdx};
        if ~isEqual(srcData.(thisFieldName),dstData.(thisFieldName))
            % Found an unsynchronized value - update from jcomp => hcomp
            %disp(['  => ' hSrc.class ' ' thisFieldName]);
            overrideSet(hDst,thisFieldName,srcData.(thisFieldName));
        end
    end

    % Check for ComponentModifiedCallback
    if isprop(hDst,'ComponentChangedCallback') && ~isempty(hDst.ComponentChangedCallback)
        overrideSet(hDst,'ComponentChangedCallbackData',eventdata);
        hgfeval(hDst.ComponentChangedCallback,hDst,eventdata);
    end
end

%% Temporarily set a property value, EVEN IF it is read-only (PublicSet='off')
function overrideSet(object,fieldName,newValue)
    try
        % Get the property's read/write indication
        sp = findprop(object,fieldName);
        oldPublicSet = sp.AccessFlags.PublicSet;

        % Temporarily allow writing, EVEN IF property is read-only (PublicSet='off')
        sp.AccessFlags.PublicSet = 'on';

        % Set the property to the new value
        set(object,fieldName,newValue);

        % Restore the property's original read/write indication
        sp.AccessFlags.PublicSet = oldPublicSet;
    catch
        %disp(lasterr);  % Never mind...
    end
end

%% Setup the component change callback hooks for internal & user-defined uses
function setupChangeCallback(hcomp,jcomp)  %#ok - unused for now: we use localGet/SetData
    try
        % Disable public access to the default StateChangedCallback (used by uicomponent below)
        set(hcomp,'StateChangedCallback',{@syncProps,jcomp,hcomp});
        sp(1) = findprop(hcomp,'StateChangedCallback');
        sp(2) = findprop(hcomp,'StateChangedCallbackData');
        % Note: unfortunately, we cannot modify existing jcomp fields (see workaround below)
        %sp(3) = findprop(jcomp,'StateChangedCallback');
        %sp(4) = findprop(jcomp,'StateChangedCallbackData');
        set(sp,'Visible','off');
        set(sp,'AccessFlags.PublicSet','off');

        % We can't prevent users from modifying jcomp.StateChangedCallback, but we can alert and revert
        prop = findprop(jcomp,'StateChangedCallback');
        if ~isempty(prop)
            propertyListeners___ = getappdata(hcomp,'propertyListeners___');
            propertyListeners___(end+1) = handle.listener(jcomp,prop,'PropertyPostSet',{@localAlertCallbackModified,jcomp,hcomp});
            setappdata(hcomp,'propertyListeners___',propertyListeners___);
        end

        % Create a publicly accessible callback hook (called by StateChangedCallback)
        clear sp;
        sp(1) = schema.prop(hcomp,'ComponentChangedCallback','mxArray');
        sp(2) = schema.prop(jcomp,'ComponentChangedCallback','mxArray');
        sp(3) = schema.prop(hcomp,'ComponentChangedCallbackData','mxArray');
        sp(4) = schema.prop(jcomp,'ComponentChangedCallbackData','mxArray');
        linkprops([hcomp,jcomp],'ComponentChangedCallback');
        set(sp(3:4),'AccessFlags.PublicSet','off');  % only CallbackData is read-only
    catch
        % never mind...
        %disp(lasterr);
    end
end

%% We can't prevent the user from modifying jcomp.StateChangedCallback, but we can alert and revert
function localAlertCallbackModified(eventsrc,eventdata,jcomp,hcomp)  %#ok
    % Send a 'soft' warning to Matlab desktop
    warning('YMA:uicomponent:InvalidCallbackModified', ...
            ['Cannot modify ''StateChangedCallback'' (used internally by uicomponent). ' ...
             'Modify ''ComponentChangedCallback'' instead.']);

    % Set ComponentChangedCallback to the requested callback
    set(jcomp,'ComponentChangedCallback',get(jcomp,'StateChangedCallback'));

    % Revert StateChangedCallback
    set(jcomp,'StateChangedCallback',{@syncProps,jcomp,hcomp});
end

%% Store the container & component's handles in the component
function storeHandles(hcomp,jcomp,hcontainer)
    try
        try
            % HG1 - R2014a or older:
            % Matlab HG container handle
            sp(1) = schema.prop(jcomp,'MatlabHGContainer','mxArray');
            sp(2) = schema.prop(hcomp,'MatlabHGContainer','mxArray');
            set([hcomp,jcomp],'MatlabHGContainer',hcontainer);
            linkprops([hcomp,jcomp],'MatlabHGContainer');

            % Java component handle (no need to store within jcomp - only in hcomp...)
            sp(3) = schema.prop(hcomp,'JavaComponent','mxArray');
            set(hcomp,'JavaComponent',jcomp);

            % Disable public set of these handles - read only
            set(sp,'AccessFlags.PublicSet','off');
        catch
            % HG2 - R2014b or newer
            try addprop(jcomp,'MatlabHGContainer'); catch, end  % probably fails, never mind
            try jcomp.MatlabHGContainer = hcontainer; catch, end  % might fail, never mind
            addprop(hcomp,'MatlabHGContainer');
            hcomp.MatlabHGContainer = hcontainer;

            hp = addprop(hcomp,'JavaComponent');
            set(hcomp,'JavaComponent',jcomp);
            hp.SetAccess = 'private';
        end

        % Store the javaclassname in the Tag property
        set(hcontainer,'Tag',get(hcontainer,'UserData'));

        % Store the handle in the container's UserData
        % Note: javacomponent placed the jcomp classname in here, but the correct place is
        % ^^^^  really in the Tag property, and use UserData to store the handle reference
        set(hcontainer,'UserData',hcomp);
    catch
        % never mind...
        %disp(lasterr);
    end
end

%% Get the relevant property value from jcomp
function propValue = localGetData(object,propValue,jcomp,propName)  %#ok
    propValue = get(jcomp,propName);
end

%% Set the relevant property value in jcomp
function propValue = localSetData(object,propValue,jcomp,propName)  %#ok
    set(jcomp,propName,propValue);
end

%% Workaround for javacomponent's bug with java.awt.Window and sub-classes...
function [jcomp, hcontainer] = javacomponentFix(javaComp,position,parent)
    % Prepare a Matlab HG container for the java component
    % Note: this container will be a child of the requested parent, while javaComp is another window!
    if isempty(position)
        % Default window size should be larger than javacomponent's default of 60x20
        position = [100,100,100,100];
    else
        % Disallow window sizes less than 100x100
        position = [position(1:2) max(position(3:4),100)];
    end
    hcontainer = hgjavacomponent('Parent',parent,'Units','Pixels','JavaPeer',javaComp,'Position', position);

    % Prepare a handle for the java component, including all available callback hooks
    jcomp = handle(javaComp,'callbackProperties');

    % Prepare deletion callbacks, so that if any of the component or container is deleted, so will the other
    set(hcontainer, 'DeleteFcn', {@componentDelete, jcomp});
    set(jcomp, 'WindowClosingCallback', {@componentDelete, hcontainer});
    hl = handle.listener(jcomp, jcomp, 'ObjectBeingDestroyed', {@componentDelete, hcontainer});
    p = schema.prop(jcomp, 'Listeners__', 'handle vector');
    set(p,'AccessFlags.Serialize','off','AccessFlags.Copy','off','FactoryValue',[],'Visible','off');
    set(jcomp, 'Listeners__', hl);

    % Set the new figure's screen position & size
    % Note: remember that Matlab origin = bottom left while java origin = top left...
    screenSize = get(0,'ScreenSize');
    jcomp.setLocation(java.awt.Point(position(1), screenSize(4)-position(2)-position(4)));
    jcomp.setSize(java.awt.Dimension(position(3), position(4)));
end

%% Callback function for Window/Frame Java component deletion
function componentDelete(obj, evd, component) %#ok - mlint
    % delete component if it exists
    if any(ishandle(component))
        delete(component);
    end
end


%% TODO TODO TODO
%{
% To add a *Frame - see C:\Program Files\Matlab 7.4\toolbox\matlab\scribe\scribealign.m:
Frame=com.mathworks.mwswing.MJFrame('Align Distribute Tool');
Panel=com.mathworks.page.scribealign.ScribeAlignmentPanel;
Frame.getContentPane.add(Panel);
Frame.setResizable(false);
Frame.pack;
Frame.show;
%}
