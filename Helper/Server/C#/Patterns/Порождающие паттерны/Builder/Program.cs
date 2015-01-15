using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Builder
{

    #region Создание различных кофигураций одно объекта
    public class HeaderData { }
    public class MenuItems { }
    public class PostData { }
    public class FooterData { }

    public interface IPageBuilder
    {
        void BuildHeader(HeaderData header);
        void BuildMenu(MenuItems menuItems);
        void BuildPost(PostData post);
        void BuildFooter(FooterData footer);
    }

    //распорядитель
    public class PageDirector
    {
        private readonly IPageBuilder _builder;
        private HeaderData GetHeader(int pageId) { return new HeaderData(); }
        private MenuItems GetMenuItems(int pageId) { return new MenuItems(); }
        private IEnumerable<PostData> GetPosts(int pageId) { return new List<PostData>(); }
        private FooterData GetFooter(int pageId) { return new FooterData(); }

        public PageDirector(IPageBuilder builder)
        {
            _builder = builder;
        }

        public void BuildPage(int pageId)
        {
            _builder.BuildHeader(this.GetHeader(pageId));
            _builder.BuildMenu(this.GetMenuItems(pageId));

            foreach (PostData postData in this.GetPosts(pageId))
            {
                _builder.BuildPost(postData);
            }

            _builder.BuildFooter(this.GetFooter(pageId));
        }
    }

    public class Page
    {
        public void AddHeader(HeaderData header)
        {

        }

        public void SetMenuItems(MenuItems menuItems)
        {

        }

        public void AddPost(PostData post)
        {

        }

        public void AddFooter(FooterData footer)
        {

        }
    }

    //строитель
    public class PageBuilder : IPageBuilder
    {
        private readonly Page _page = new Page();
        public void BuildHeader(HeaderData header) { _page.AddHeader(header); }
        public void BuildMenu(MenuItems menuItems) { _page.SetMenuItems(menuItems); }
        public void BuildPost(PostData post) { _page.AddPost(post); }
        public void BuildFooter(FooterData footer) { _page.AddFooter(footer); }
        public Page GetResult() { return _page; }
    }

    #endregion

    #region SecondExample
    // This is the "Product" class
    public class MobilePhone
    {
        // fields to hold the part type
        string phoneName;
        ScreenType phoneScreen;
        Battery phoneBattery;
        OperatingSystem phoneOS;
        Stylus phoneStylus;

        public MobilePhone(string name)
        {
            phoneName = name;
        }

        // Public properties to access phone parts

        public string PhoneName
        {
            get { return phoneName; }
        }

        public ScreenType PhoneScreen
        {
            get { return phoneScreen; }
            set { phoneScreen = value; }
        }

        public Battery PhoneBattery
        {
            get { return phoneBattery; }
            set { phoneBattery = value; }
        }

        public OperatingSystem PhoneOS
        {
            get { return phoneOS; }
            set { phoneOS = value; }
        }

        public Stylus PhoneStylus
        {
            get { return phoneStylus; }
            set { phoneStylus = value; }
        }

        // Methiod to display phone details in our own representation
        public override string ToString()
        {
            return string.Format("Name: {0}\nScreen: {1}\nBattery {2}\nOS: {3}\nStylus: {4}",
                PhoneName, PhoneScreen, PhoneBattery, PhoneOS, PhoneStylus);
        }
    }

    // This is the "Builder" interface
    public interface IPhoneBuilder
    {
        void BuildScreen();
        void BuildBattery();
        void BuildOS();
        void BuildStylus();
        MobilePhone Phone { get; }
    }

    // Builder
    class AndroidPhoneBuilder : IPhoneBuilder
    {
        MobilePhone phone;

        public AndroidPhoneBuilder()
        {
            phone = new MobilePhone("Android Phone");
        }

        #region IPhoneBuilder Members

        public void BuildScreen()
        {
            phone.PhoneScreen = ScreenType.ScreenType_TOUCH_RESISTIVE;
        }

        public void BuildBattery()
        {
            phone.PhoneBattery = Battery.MAH_1500;
        }

        public void BuildOS()
        {
            phone.PhoneOS = OperatingSystem.ANDROID;
        }

        public void BuildStylus()
        {
            phone.PhoneStylus = Stylus.YES;
        }

        // GetResult Method which will return the actual phone
        public MobilePhone Phone
        {
            get { return phone; }
        }

        #endregion
    }

    // Builder
    class WindowsPhoneBuilder : IPhoneBuilder
    {
        MobilePhone phone;

        public WindowsPhoneBuilder()
        {
            phone = new MobilePhone("Windows Phone");
        }

        #region IPhoneBuilder Members

        public void BuildScreen()
        {
            phone.PhoneScreen = ScreenType.ScreenType_TOUCH_CAPACITIVE;
        }

        public void BuildBattery()
        {
            phone.PhoneBattery = Battery.MAH_2000;
        }

        public void BuildOS()
        {
            phone.PhoneOS = OperatingSystem.WINDOWS_PHONE;
        }

        public void BuildStylus()
        {
            phone.PhoneStylus = Stylus.NO;
        }

        // GetResult Method which will return the actual phone
        public MobilePhone Phone
        {
            get { return phone; }
        }

        #endregion
    }
    #endregion


    // This is the "Director" class - распорядитель
    public class Director
    {
        public void Build(IPhoneBuilder phoneBuilder)
        {
            phoneBuilder.BuildBattery();
            phoneBuilder.BuildOS();
            phoneBuilder.BuildScreen();
            phoneBuilder.BuildStylus();
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            #region Client

            Director director = new Director();

            IPhoneBuilder phoneBuilder;

            //Create andriod
            phoneBuilder = new AndroidPhoneBuilder();
            director.Build(phoneBuilder);

            MobilePhone phone = phoneBuilder.Phone; 
            #endregion
        }




    }



    // Some helper enums to identify various parts
    public enum ScreenType
    {
        ScreenType_TOUCH_CAPACITIVE,
        ScreenType_TOUCH_RESISTIVE,
        ScreenType_NON_TOUCH
    };

    public enum Battery
    {
        MAH_1000,
        MAH_1500,
        MAH_2000
    };

    public enum OperatingSystem
    {
        ANDROID,
        WINDOWS_MOBILE,
        WINDOWS_PHONE,
        SYMBIAN
    };

    public enum Stylus
    {
        YES,
        NO
    };
}
