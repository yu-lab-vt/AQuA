function [p,ep,st]=createScreenshot
  clf
  clear java all
  set(gcf,'Position',[200,200,630,420],'NumberTitle','off','Name','UICOMPONENT examples');
  h=uipanel;
  %p=handle([]);
% {
  p       =uicomponent('style','filechooser','position',[5,5,400,400]);
  p(end+1)=uicomponent('style','JLabel',{'JFileChooser:'},'position',[10,400,100,15],'foreground',java.awt.Color.red);
  p(end+1)=uicomponent('style','jslider',{},'pos',[410,5,70,120],'Value',72,'Orientation',1,'MajorTickSpacing',20,'MinorTickSpacing',5,'Paintlabels',1,'PaintTicks',1);
  p(end+1)=uicomponent('style','jslider',{},'pos',[480,5,130,40],'Value',57,'Orientation',0);
  p(end+1)=uicomponent('style','jslider',{},'pos',[480,40,130,40],'Value',22,'Orientation',0,'MajorTickSpacing',20,'PaintTicks',1);
  p(end+1)=uicomponent('style','jslider',{},'pos',[480,80,130,40],'Value',84,'Orientation',0,'MajorTickSpacing',20,'PaintLabels',1);
  p(end+1)=uicomponent('style','JLabel',{'JSlider (several options):'},'position',[430,120,150,15],'foreground',java.awt.Color.red);
  p(end+1)=uicomponent('style','JComboBox',{'Option 1','Option 2','Option 3'},'position',[450,140,150,20],'editable',true,'SelectedItem',' I can edit this...');
  p(end+1)=uicomponent('style','JLabel',{'JComboBox (editable):'},'position',[430,160,150,15],'foreground',java.awt.Color.red);
  p(end+1)=uicomponent('style','JSpinner','position',[520,180,80,20],'value',7);
  p(end+1)=uicomponent('style','JLabel',{'JSpinner:'},'position',[430,180,50,20],'foreground',java.awt.Color.red);
  p(end+1)=uicomponent('style','JPasswordField','position',[520,210,80,20],'Text','testing');
  p(end+1)=uicomponent('style','JLabel',{'JPasswordField:'},'position',[430,210,80,20],'foreground',java.awt.Color.red);
  p(end+1)=uicomponent('style','JProgressBar','position',[520,240,80,20],'StringPainted',1,'Value',77.5,'Indeterminate',0);
  % Note: without 'StringPainted' or 'StringPainted',0 for green blocks, not continuous blue...
%}
  p(end+1)=uicomponent('style','JLabel',{'JProgressBar:'},'position',[430,240,80,20],'foreground',java.awt.Color.red);

  %url = java.net.URL(['jar:file:///' strrep(matlabroot,'\','/') '/help/techdoc/help.jar!/ref/plot.html']);
  %url = java.net.URL(['file:///' strrep(matlabroot,'\','/') '/help/matlab/matlab_external/userdata.html']);
  %url = java.net.URL('http://google.com');
  url = java.net.URL('http://java.sun.com/docs/books/tutorial/uiswing/components/examples/TextSamplerDemoHelp.html');
  url = java.net.URL('http://docs.oracle.com/javase/tutorial/uiswing/examples/components/TextSamplerDemoProject/src/components/TextSamplerDemoHelp.html');
  ep = javaObjectEDT(handle(javax.swing.JEditorPane(url), 'CallbackProperties'));
  pause(1);
  try
      text = char(ep.getText);
      st = regexprep(evalc('type ..\docstyle.css'),'/\*.*?\*/','');
      ep.setText(regexprep(text,{'<!--.*?>','(</head>)'},{'',['<style type="text/css">' st '</style>$1']}));
      set(ep,'PropertyChangeCallback',{@callbackFcn,st})
  catch
      % never mind...
  end
  ep.setEditable(false);
  ep.addHyperlinkListener(HyperlinkListenerImp);
  set(ep,'HyperlinkUpdateCallback',@callbackFcn2)
  sp=javax.swing.JScrollPane(ep);
  sp.setHorizontalScrollBarPolicy(sp.HORIZONTAL_SCROLLBAR_AS_NEEDED);
  sp.setVerticalScrollBarPolicy(sp.VERTICAL_SCROLLBAR_AS_NEEDED);
  %p(end+1)=uicomponent('style','JEditorPane','position',[400,270,210,140],'Page',url);
  p(end+1)=uicomponent(sp,'position',[400,270,210,140]);
end

function callbackFcn(src,evt,st)
  if strcmpi(evt.getPropertyName,'page')
    oldCb = get(evt.getSource,'PropertyChangeCallback');
    set(evt.getSource,'PropertyChangeCallback',[]);
    %pause(1)
    text = char(evt.getSource.getText);
    evt.getSource.setText(regexprep(text,{'<!--.*?>','(</head>)'},{'',['<style type="text/css">' st '</style>$1']}));
    pause(1);
    set(evt.getSource,'PropertyChangeCallback',oldCb);
  end
end

function callbackFcn2(src,evt)
  if ~ishandle(evt),  return;  end
  %disp(evt.getURL)
  %disp(evt.getDescription)
  evt.getSource.setToolTipText(['<html>&nbsp;<b>' char(evt.getDescription) '</b><br>&nbsp;' char(evt.getURL.toString) '</html>']);
end
