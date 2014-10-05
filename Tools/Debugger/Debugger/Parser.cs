using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;
using System.Threading;
using System.IO;
using System.Xml;


namespace Debugger
{
    class Parser// : IDisposable
    {
        private InterruptHandler _interruptHandler;

        public Parser()
        {
            _interruptHandler = new InterruptHandler();
            _interruptHandler.RunInNewThread(false);
        }

        public async void Parse(Stream stream)
        {
            using (XmlReader reader = XmlReader.Create(stream, new XmlReaderSettings() { Async = true }))
            {
              //  try
                //{
                    while (await reader.ReadAsync())
                    {
                        Console.WriteLine("|ss");
                        switch (reader.NodeType)
                        {
                            case XmlNodeType.Element:
                                Console.WriteLine(await reader.ReadAsync());
                                if (reader.Name == "Interrupt")
                                    InterruptParse(reader);
                                 break;

                            /*case XmlNodeType.Text:
                                Console.WriteLine(reader.Value);
                                break;*/
                        }
                    }
            /*    }
                catch
                {

                }*/
            }
        }

        public void Dispose()
        {
            _interruptHandler.Destory();
        }


        private void InterruptParse(XmlReader reader)
        {
            string[] str = new string[6];

            for(int i = 0; i < 6; i++)
            {
                reader.MoveToNextAttribute();
                string irq = reader.Value;
            }

            _interruptHandler.AddEntry(str);
        }
    }




    internal static class FormExtensions
    {
        private static void ApplicationRunProc(object state)
        {
            Application.Run(state as Form);
        }

        public static void RunInNewThread(this Form form, bool isBackground)
        {
            if (form == null)
                throw new ArgumentNullException("form");
            if (form.IsHandleCreated)
                throw new InvalidOperationException("Form is already running.");

            Thread thread = new Thread(ApplicationRunProc);
            thread.SetApartmentState(ApartmentState.STA);
            thread.IsBackground = isBackground;
            thread.Start(form);
        }
    }
}
