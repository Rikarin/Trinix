namespace Debugger
{
    partial class InterruptHandler
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.IRQ = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.RIP = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.RBP = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.RSP = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.CS = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.SS = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.IRQ,
            this.RIP,
            this.RBP,
            this.RSP,
            this.CS,
            this.SS});
            this.dataGridView1.Location = new System.Drawing.Point(12, 12);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.Size = new System.Drawing.Size(750, 179);
            this.dataGridView1.TabIndex = 0;
            // 
            // IRQ
            // 
            this.IRQ.HeaderText = "IRQ";
            this.IRQ.Name = "IRQ";
            // 
            // RIP
            // 
            this.RIP.HeaderText = "RIP";
            this.RIP.Name = "RIP";
            // 
            // RBP
            // 
            this.RBP.HeaderText = "RBP";
            this.RBP.Name = "RBP";
            // 
            // RSP
            // 
            this.RSP.HeaderText = "RSP";
            this.RSP.Name = "RSP";
            // 
            // CS
            // 
            this.CS.HeaderText = "CS";
            this.CS.Name = "CS";
            // 
            // SS
            // 
            this.SS.HeaderText = "SS";
            this.SS.Name = "SS";
            // 
            // InterruptHandler
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(774, 203);
            this.Controls.Add(this.dataGridView1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Name = "InterruptHandler";
            this.Text = "InterruptHandler";
            this.Load += new System.EventHandler(this.InterruptHandler_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.DataGridViewTextBoxColumn IRQ;
        private System.Windows.Forms.DataGridViewTextBoxColumn RIP;
        private System.Windows.Forms.DataGridViewTextBoxColumn RBP;
        private System.Windows.Forms.DataGridViewTextBoxColumn RSP;
        private System.Windows.Forms.DataGridViewTextBoxColumn CS;
        private System.Windows.Forms.DataGridViewTextBoxColumn SS;
    }
}