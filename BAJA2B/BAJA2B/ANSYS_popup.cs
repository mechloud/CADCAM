using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BAJA2B
{
    public partial class ANSYS_popup : Form
    {
        public ANSYS_popup()
        {
            InitializeComponent(); 
        }

        public bool front { get; set; }
        public bool rear { get; set; }
        public bool side { get; set; }
        public bool roll { get; set; }

        private void btn_CANCEL_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btn_OK_Click(object sender, EventArgs e)
        {
            // First show the index and check state of all selected items.
            foreach (int indexChecked in ANSYS_selection.CheckedIndices)
            {
                switch (indexChecked)
                {
                    case 0:
                        front = true;
                        break;
                    case 1:
                        rear = true;
                        break;
                    case 2:
                        side = true;
                        break;
                    case 3:
                        roll = true;
                        break;
                }
            }

            this.Close();
        }
        
    }
}
