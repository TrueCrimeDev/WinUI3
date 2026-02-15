#Requires AutoHotkey v2.0
#Include DotNet.ahk

#SingleInstance Force

csharpCode := "
(
using System;
using System.Windows.Forms;
using System.Drawing;
using System.Data;

public class UniqueControlsGui
{
    public void ShowGui()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        Form form = new Form();
        form.Text = "Controls That DON'T EXIST in AHK!";
        form.Width = 800;
        form.Height = 600;
        form.StartPosition = FormStartPosition.CenterScreen;

        // Create TabControl to organize
        TabControl tabs = new TabControl();
        tabs.Dock = DockStyle.Fill;

        // === TAB 1: DataGridView ===
        TabPage tab1 = new TabPage("DataGridView");
        DataGridView grid = new DataGridView();
        grid.Dock = DockStyle.Fill;
        grid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        grid.AllowUserToAddRows = true;
        grid.AllowUserToDeleteRows = true;

        // Add columns
        grid.Columns.Add("Name", "Name");
        grid.Columns.Add("Age", "Age");
        grid.Columns.Add("City", "City");

        // Add checkbox column (AHK can't do this!)
        DataGridViewCheckBoxColumn checkCol = new DataGridViewCheckBoxColumn();
        checkCol.HeaderText = "Active";
        checkCol.Name = "Active";
        grid.Columns.Add(checkCol);

        // Add combobox column (AHK can't do this!)
        DataGridViewComboBoxColumn comboCol = new DataGridViewComboBoxColumn();
        comboCol.HeaderText = "Status";
        comboCol.Items.AddRange("Pending", "Approved", "Rejected");
        grid.Columns.Add(comboCol);

        // Add sample data
        grid.Rows.Add("Alice", 28, "New York", true, "Approved");
        grid.Rows.Add("Bob", 35, "Los Angeles", true, "Pending");
        grid.Rows.Add("Charlie", 42, "Chicago", false, "Rejected");

        tab1.Controls.Add(grid);

        // === TAB 2: MonthCalendar ===
        TabPage tab2 = new TabPage("MonthCalendar");
        Panel calPanel = new Panel();
        calPanel.Dock = DockStyle.Fill;

        MonthCalendar calendar = new MonthCalendar();
        calendar.Location = new Point(20, 20);
        calendar.MaxSelectionCount = 30;
        calendar.ShowTodayCircle = true;
        calendar.ShowWeekNumbers = true;
        // Bold some dates
        calendar.BoldedDates = new DateTime[] {
            DateTime.Today,
            DateTime.Today.AddDays(7),
            DateTime.Today.AddDays(14)
        };
        calPanel.Controls.Add(calendar);

        Label calLabel = new Label();
        calLabel.Text = "This is a REAL calendar control with week numbers,\nbold dates, and multi-select. AHK doesn't have this!";
        calLabel.Location = new Point(250, 20);
        calLabel.Size = new Size(300, 50);
        calPanel.Controls.Add(calLabel);

        tab2.Controls.Add(calPanel);

        // === TAB 3: NumericUpDown + DomainUpDown ===
        TabPage tab3 = new TabPage("Spinners");
        Panel spinPanel = new Panel();
        spinPanel.Dock = DockStyle.Fill;

        Label lbl1 = new Label();
        lbl1.Text = "NumericUpDown (number spinner):";
        lbl1.Location = new Point(20, 20);
        lbl1.AutoSize = true;
        spinPanel.Controls.Add(lbl1);

        NumericUpDown numSpinner = new NumericUpDown();
        numSpinner.Location = new Point(20, 45);
        numSpinner.Size = new Size(120, 25);
        numSpinner.Minimum = 0;
        numSpinner.Maximum = 1000;
        numSpinner.Value = 50;
        numSpinner.Increment = 5;
        numSpinner.DecimalPlaces = 2;
        spinPanel.Controls.Add(numSpinner);

        Label lbl2 = new Label();
        lbl2.Text = "DomainUpDown (text spinner):";
        lbl2.Location = new Point(20, 90);
        lbl2.AutoSize = true;
        spinPanel.Controls.Add(lbl2);

        DomainUpDown domainSpinner = new DomainUpDown();
        domainSpinner.Location = new Point(20, 115);
        domainSpinner.Size = new Size(150, 25);
        domainSpinner.Items.Add("Small");
        domainSpinner.Items.Add("Medium");
        domainSpinner.Items.Add("Large");
        domainSpinner.Items.Add("Extra Large");
        domainSpinner.SelectedIndex = 1;
        domainSpinner.Wrap = true;
        spinPanel.Controls.Add(domainSpinner);

        Label lbl3 = new Label();
        lbl3.Text = "AHK has NO spinner controls!\nThese are .NET exclusive.";
        lbl3.Location = new Point(200, 45);
        lbl3.Size = new Size(200, 50);
        lbl3.ForeColor = Color.Red;
        spinPanel.Controls.Add(lbl3);

        tab3.Controls.Add(spinPanel);

        // === TAB 4: PropertyGrid ===
        TabPage tab4 = new TabPage("PropertyGrid");
        PropertyGrid propGrid = new PropertyGrid();
        propGrid.Dock = DockStyle.Fill;
        propGrid.SelectedObject = form; // Show form's own properties!
        tab4.Controls.Add(propGrid);

        // === TAB 5: RichTextBox ===
        TabPage tab5 = new TabPage("RichTextBox");
        RichTextBox rtb = new RichTextBox();
        rtb.Dock = DockStyle.Fill;
        rtb.SelectionFont = new Font("Arial", 16, FontStyle.Bold);
        rtb.SelectionColor = Color.Blue;
        rtb.AppendText("This is BOLD and BLUE text!\n\n");
        rtb.SelectionFont = new Font("Arial", 12, FontStyle.Italic);
        rtb.SelectionColor = Color.Green;
        rtb.AppendText("This is italic and green!\n\n");
        rtb.SelectionFont = new Font("Courier New", 10, FontStyle.Underline);
        rtb.SelectionColor = Color.Red;
        rtb.AppendText("This is underlined monospace in red!\n\n");
        rtb.SelectionFont = new Font("Arial", 11, FontStyle.Regular);
        rtb.SelectionColor = Color.Black;
        rtb.AppendText("AHK's Edit control cannot do mixed formatting like this!");
        tab5.Controls.Add(rtb);

        // === TAB 6: WebBrowser ===
        TabPage tab6 = new TabPage("WebBrowser");
        WebBrowser browser = new WebBrowser();
        browser.Dock = DockStyle.Fill;
        browser.DocumentText = @"
            <html>
            <body style='font-family: Segoe UI; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px;'>
                <h1>Embedded Web Browser!</h1>
                <p>This is an actual <b>WebBrowser control</b> rendering HTML.</p>
                <p>AHK cannot embed a browser control natively!</p>
                <button onclick='alert(""JavaScript works too!"")'>Click Me</button>
                <hr>
                <p style='font-size: 12px;'>Powered by .NET System.Windows.Forms.WebBrowser</p>
            </body>
            </html>";
        tab6.Controls.Add(browser);

        // Add all tabs
        tabs.TabPages.Add(tab1);
        tabs.TabPages.Add(tab2);
        tabs.TabPages.Add(tab3);
        tabs.TabPages.Add(tab4);
        tabs.TabPages.Add(tab5);
        tabs.TabPages.Add(tab6);

        form.Controls.Add(tabs);

        // Show
        Application.Run(form);
    }
}
)"

try {

    assembly := DotNet.CompileAssembly(csharpCode)
    myGui := assembly.CreateInstance("UniqueControlsGui")
    myGui.ShowGui()

} catch as e {
    MsgBox("Error:`n" e.Message "`n`n" (e.HasProp("Extra") ? e.Extra : ""), "Error")
}

ExitApp
