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
    public partial class Main : Form
    {
        public Main()
        {
            InitializeComponent();
        }

        // Generate CAD model
        private void btn_generate_Click(object sender, EventArgs e)
        {

            // Write ANSYS output file if desired
            if (cb_ANSYS_script.Checked == true)
            {
                output_ansys.write_to_file("front");
            }
            
            // Close the form after generating the Solidworks model, this is temporary.
            this.Close();
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

        private void cb_ANSYS_script_CheckedChanged(object sender, EventArgs e)
        {
            var form = new ANSYS_popup();
            if (cb_ANSYS_script.Checked == true)
            {
                form.front = false;
                form.rear = false;
                form.side = false;
                form.roll = false;
                form.ShowDialog(this);
            }
            else
            {
                form.front = false;
                form.rear = false;
                form.side = false;
                form.roll = false;
            }
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
                if (box_steering_ratio.Text.GetType() != typeof(Int32))
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


        // Frame Height
        private void tb_frame_height_Scroll(object sender, EventArgs e)
        {
            box_frame_height.Text = Convert.ToString(tb_frame_height.Value);
        }

        private void box_frame_height_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                get_frame_height();
            }
        }

        private void box_frame_height_Leave(object sender, EventArgs e)
        {
            get_frame_height();
        }

        private void get_frame_height()
        {
            int frame_height;

            try
            {
                frame_height = Convert.ToInt32(box_frame_height.Text);
            }
            catch
            {
                if (box_frame_height.Text.GetType() != typeof(Int32))
                {
                    MessageBox.Show("Entries must be integers.");
                }
                frame_height = 4;
            }

            int fh_max = tb_frame_height.Maximum;
            int fh_min = tb_frame_height.Minimum;

            frame_height = boundary_check(frame_height, fh_max, fh_min);

            tb_frame_height.Value = frame_height;
            box_frame_height.Text = Convert.ToString(frame_height);
        }

        // Frame Width
        private void tb_frame_width_Scroll(object sender, EventArgs e)
        {
            box_frame_width.Text = Convert.ToString(tb_frame_width.Value);
        }

        private void box_frame_width_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                get_frame_width();
            }
        }

        private void box_frame_width_Leave(object sender, EventArgs e)
        {
            get_frame_width();
        }

        private void get_frame_width()
        {
            int frame_width;

            try
            {
                frame_width = Convert.ToInt32(box_frame_width.Text);
            }
            catch
            {
                if (box_frame_width.Text.GetType() != typeof(Int32))
                {
                    MessageBox.Show("Entries must be integers.");
                }
                frame_width = 4;
            }

            int fw_max = tb_frame_width.Maximum;
            int fw_min = tb_frame_width.Minimum;

            frame_width = boundary_check(frame_width, fw_max, fw_min);

            tb_frame_width.Value = frame_width;
            box_frame_width.Text = Convert.ToString(frame_width);
        }

        // Wheel Base
        private void tb_wheelbase_Scroll(object sender, EventArgs e)
        {
            box_wheelbase.Text = Convert.ToString(tb_wheelbase.Value);
        }

        private void box_wheelbase_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                get_wheelbase();
            }
        }

        private void box_wheelbase_Leave(object sender, EventArgs e)
        {
            get_wheelbase();
        }

        private void get_wheelbase()
        {
            int wheelbase;

            try
            {
                wheelbase = Convert.ToInt32(box_wheelbase.Text);
            }
            catch
            {
                if (box_wheelbase.Text.GetType() != typeof(Int32))
                {
                    MessageBox.Show("Entries must be integers.");
                }
                wheelbase = 4;
            }

            int wb_max = tb_wheelbase.Maximum;
            int wb_min = tb_wheelbase.Minimum;

            wheelbase = boundary_check(wheelbase, wb_max, wb_min);

            tb_wheelbase.Value = wheelbase;
            box_wheelbase.Text = Convert.ToString(wheelbase);
        }

    }
   
}

