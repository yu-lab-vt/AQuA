// HyperlinkListener - class for handling JEditorPane hyperlink events
// see: http://java.sun.com/j2se/1.4.2/docs/api/javax/swing/JEditorPane.html
import java.io.*;
import javax.swing.*;
import javax.swing.event.*;
public class HyperlinkListenerImp implements HyperlinkListener {
    public void hyperlinkUpdate(HyperlinkEvent evt) {
        if (evt.getEventType() == HyperlinkEvent.EventType.ACTIVATED) {
            JEditorPane pane = (JEditorPane)evt.getSource();
            try {
                // Show the new page in the editor pane.
                pane.setPage(evt.getURL());
            } catch (IOException e) {
            }
        }
    }
}
