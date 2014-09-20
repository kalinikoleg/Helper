
using LINQtoCSV;


        protected void btnExportToCsv_Click(object sender, EventArgs e)
        {            
           IQueryable<PrePayCodesForListPage> list = PrePayCodesProvider.GetAllForListPage()
                .OrderBy(x => x.Date_Created)
                .Select(z => new PrePayCodesForListPage
                {
                    Affiliate = z.Affiliate.Trim(),
                    Code = z.Code.Trim(),
                    Course = z.Course.Trim(),
                    Date_Created = z.Date_Created,
                    Date_Used = z.Date_Used,
                    Disabled = z.Disabled,
                    ExpirationDate = z.ExpirationDate,
                    ID = z.ID,
                    Login_Name = z.Login_Name.Trim(),
                    ReasonCodeID = z.ReasonCodeID
                });

            string from = dateFrom.Text.Trim();
            string until = dateUntil.Text.Trim();
            list = GetListWithDateRange(list, from, until, ddlAffilatedFilter.SelectedItem.Text);

            string path = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "PrepayCode.csv");

            if (File.Exists(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "PrepayCode.csv")))
            {
                File.Delete(path);
            }

            File.Create(path).Close();

            CsvContext context = new CsvContext();

            CsvFileDescription fileDescription = new CsvFileDescription
            {
                SeparatorChar = '\t',
                FirstLineHasColumnNames = true,
                EnforceCsvColumnAttribute = false,
                TextEncoding = Encoding.Unicode,
                FileCultureName = "en-US"
            };

            bool isFileCSVAvailable = true;
            try
            {
                context.Write<PrePayCodesForListPage>(
                    list,
                    path,
                    fileDescription);
                FileInfo myfile = new FileInfo(path);

                Response.ClearContent();
                Response.AddHeader("Content-Disposition", "attachment; filename=" + myfile.Name);
                Response.AddHeader("Content-Length", myfile.Length.ToString());
                Response.ContentType = "application/octet-stream";
                Response.TransmitFile(myfile.FullName);
            }
            catch(Exception)
            {
                isFileCSVAvailable = false;
            }

            if (isFileCSVAvailable)
            {
                Response.Flush();
                File.Delete(path);
                Response.End();
            }
 }