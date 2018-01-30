using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Windows.Forms;

namespace BAJA2B
{
    public class output_ansys
    {
        public string impact { get; set; }

        public static void write_to_file(string type)
        {
            try
            {
                StreamWriter file = new StreamWriter("C:\\Users\\Jonathan\\Documents\\UOttawa\\MCG4322 - CADCAM\\GitHub\\CADCAM\\BAJA2B\\test.txt");
                file.WriteLine("{0}",type);
                file.Close();
            }
            catch (Exception e)
            {
                MessageBox.Show("Could not write to file");
            }

        }
    }
}
