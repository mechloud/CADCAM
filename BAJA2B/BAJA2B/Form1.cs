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
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        // Generate CAD model
        private void btn_generate_Click(object sender, EventArgs e)
        {
            MessageBox.Show("I think this worked!");
        }

        // Close the window
        private void btn_close_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        // Check for out of bounds
        private int boundary_check(int value, int upper, int lower)
        {
            if (value > upper)
            {
                return upper;
            }
            else if (value < lower)
            {
                return lower;
            }
            else
            {
                return value;
            }
        }

        private void rb_ansys_CheckedChanged(object sender, EventArgs e)
        {
            MessageBox.Show("Need to give options in a new form or something");
        }

        // Steering Ratio
        private void box_steering_ratio_Leave(object sender, EventArgs e)
        {
            get_steering_ratio();
        }

        private void box_steering_ratio_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                get_steering_ratio();
            }
        }
        
        private void tb_steering_ratio_Scroll(object sender, EventArgs e)
        {
            box_steering_ratio.Text = Convert.ToString(tb_steering_ratio.Value);
        }

        private void get_steering_ratio()
        {
            int steering_ratio;

            try
            {
                steering_ratio = Convert.ToInt32(box_steering_ratio.Text);
            }
            catch (System.FormatException e)
            {
                if(box_steering_ratio.Text.GetType() != typeof(Int32))
                {
                    MessageBox.Show("Entries must be integers.");
                }
                steering_ratio = 4;
            }

            int sr_max = tb_steering_ratio.Maximum;
            int sr_min = tb_steering_ratio.Minimum;

            steering_ratio = boundary_check(steering_ratio, sr_max, sr_min);

            tb_steering_ratio.Value = steering_ratio;
            box_steering_ratio.Text = Convert.ToString(steering_ratio);
        }
        
        // Ground Clearance
        private void tb_ground_clearance_Scroll(object sender, EventArgs e)
        {
            box_ground_clearance.Text = Convert.ToString(tb_ground_clearance.Value);
        }

        private void box_ground_clearance_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                MessageBox.Show("Pete de plote");
                get_ground_clearance();
            }
            
        }

        private void box_ground_clearance_Leave(object sender, EventArgs e)
        {
            get_ground_clearance();
        }

        private void get_ground_clearance()
        {
            int ground_clearance;

            try
            {
                ground_clearance = Convert.ToInt32(box_ground_clearance.Text);
            }
            catch (System.FormatException e)
            {
                if (box_ground_clearance.Text.GetType() != typeof(Int32))
                {
                    MessageBox.Show("Entries must be integers.");
                }
                ground_clearance = 4;
            }

            int gc_max = tb_ground_clearance.Maximum;
            int gc_min = tb_ground_clearance.Minimum;

            ground_clearance = boundary_check(ground_clearance, gc_max, gc_min);

            tb_ground_clearance.Value = ground_clearance;
            box_ground_clearance.Text = Convert.ToString(ground_clearance);
        }
        
   
    }
}
