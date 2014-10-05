using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Debugger
{
    public partial class InterruptHandler : Form
    {
        public InterruptHandler()
        {
            InitializeComponent();
        }

        private void InterruptHandler_Load(object sender, EventArgs e)
        {
        }

        public void AddEntry(params Object[] value)
        {
            Invoke((MethodInvoker)delegate()
            {
                dataGridView1.Rows.Add(value);
            });
        }

        public void Destory()
        {
            Invoke((MethodInvoker)delegate()
            {
                Close();
            });
        }
    }
}
