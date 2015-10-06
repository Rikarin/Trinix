module System.AppKit;


/* Delegates  */

/* Enums      */

/* Interfaces */

/* Structs    */

/* Classes    */
public import System.AppKit.Box;
public import System.AppKit.View;
public import System.AppKit.Text;
public import System.AppKit.Button;
public import System.AppKit.Window;
public import System.AppKit.Matrix;
public import System.AppKit.Slider;
public import System.AppKit.TabView;
public import System.AppKit.Control;
public import System.AppKit.Browser;
public import System.AppKit.Control;
public import System.AppKit.Stepper;
public import System.AppKit.ClipView;
public import System.AppKit.Scroller;
public import System.AppKit.Responder;
public import System.AppKit.TextField;
public import System.AppKit.RulerView;
public import System.AppKit.SplitView;
public import System.AppKit.StackView;
public import System.AppKit.ImageView;
public import System.AppKit.TableView;
public import System.AppKit.OpenGLView;
public import System.AppKit.ScrollView;
public import System.AppKit.DatePicker;
public import System.AppKit.RuleEditor;
public import System.AppKit.PathControl;
public import System.AppKit.Application;
public import System.AppKit.VisualEffect;
public import System.AppKit.TableRowView;
public import System.AppKit.TableCellView;
public import System.AppKit.LevelIndicator;
public import System.AppKit.ViewController;
public import System.AppKit.CollectionView;
public import System.AppKit.TableHeaderView;
public import System.AppKit.WindowController;
public import System.AppKit.SegmentedControl;
public import System.AppKit.ProgressIndicator;




/*
 * pri mouse eventoch proste iba brat to co je pod mysou ako main
 * pri klavesnici mat vzdy vybraty jeden View ako active a z TABom alebo mouse clickom ich prepinat na iny active
 * mouse clickom sa proste posle first responderovy on mouse click a ten si to nastavi na active
 * pri tabe sa posunie v liste na dalsieho respondera. ak je na konci tak parent a jeho prvy potomok
 * 
 * 
 * EventArgs
 * Event!T
 * 
 * */