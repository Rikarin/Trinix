using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.IO;
using System.IO.Pipes;


namespace Debugger
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.Title = "Log - Trinix";

            if (!Directory.Exists("Logs"))
                Directory.CreateDirectory("Logs");

            Parser parser = null;
            while (true)
            {
                NamedPipeServerStream pipeServer = new NamedPipeServerStream("trinix");
                pipeServer.WaitForConnection();

                if (parser != null)
                    parser.Dispose();

              //  MemoryStream ms = new MemoryStream();
                //parser = new Parser();
               // parser.Parse(ms);
                StreamWriter log = new StreamWriter("Logs\\" + String.Format("{0:yyyy-MM-dd-HH-mm-ss}", DateTime.Now) + ".log");

                try
                {
                    while (pipeServer.IsConnected)
                    {
                        int v = pipeServer.ReadByte();

                        if (v == -1)
                            break;

                       // ms.WriteByte((byte)v);
                        Console.Write((char)v);
                        log.Write((char)v);
                    }

                    pipeServer.Close();
                    log.Close();
                }
                catch
                {
                }

                Console.Write(Environment.NewLine);
                Console.WriteLine("----------- Connection ended -----------");
                Console.Write(Environment.NewLine);
            }
        }
    }
}
