using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace _04zarovnaniViceSouboru
{
    public interface IWordReader
    {
        string vratSlovo();
        void zacatekPrvnihoSouboru();
        bool konecSouboru { get; }
        int pocetEnteru { get; set; }
    }
    public interface IFileProcessor
    {
        IWordReader dalsiSoubor();
        void zavriSr();
    }
    class Program
    {
        static void Main(string[] args)
        {
            StreamWriter sw;
            int delkaRadku;
            string[] soubory;
            bool zvyrazneniBilych;
            if (!vyresParametry(args, out soubory, out sw, out delkaRadku, out zvyrazneniBilych))
                return;
            IFileProcessor fileProcessor =  new FileProcessor(soubory, " \n\t\r");
            MyWriter myWriter = new MyWriter(sw, fileProcessor, delkaRadku, zvyrazneniBilych);
            myWriter.ZarovnejVypis();
            sw.Close();
        }
        private static bool vyresParametry(string[] args, out string[] soubory, out StreamWriter sw, out int delkaRadku, out bool zvyrazneniBilych)
        {
            soubory = null;
            sw = null;
            delkaRadku = 0;
            zvyrazneniBilych = false;
            int minimalneParametru = 3;
            if (args.Length == 0)
            {
                Console.WriteLine("Argument Error");
                return false;
            }
            if (args[0] == "--highlight-spaces")
            {
                minimalneParametru = 4;
                zvyrazneniBilych = true;
            }
            if (args.Length < minimalneParametru || !int.TryParse(args[args.Length - 1], out delkaRadku) || delkaRadku < 0)
            {
                Console.WriteLine("Argument Error");
                return false;
            }
            try
            {
                sw = new StreamWriter(args[args.Length - 2]);
            }
            catch (IOException)
            {
                Console.WriteLine("File Error");
                return false;
            }
            soubory = castPole(args, minimalneParametru - 3, 2);
            return true;
        }
        private static T[] castPole<T>(T[] pole, int zacatek, int konec)
        {
            T[] arr = new T[pole.Length - zacatek - konec];
            if (pole.Length > zacatek + konec)
            {
                for (int i = zacatek; i < pole.Length - konec; i++)
                {
                    arr[i - zacatek] = pole[i];
                }
            }
            return arr;
            
        }
        
    }
    public class FileProcessor : IFileProcessor
    {
        string[] soubory;
        TextReader sr;
        WordReader reader;
        int cisloSouboru = 0;
        string delimitry;
        int pocetEnteru = 0;
        public FileProcessor(string[] soubory, string delimitry)
        {
            this.soubory = soubory;
            this.delimitry = delimitry;
        }
        /// <summary>
        /// zkousi postupne soubory z argumentu, kdyz nejaky jde otevrit, priradi ho do sr (kdyz to slo, vrati true, jinak false)
        /// </summary>
        /// <returns></returns>
        public IWordReader dalsiSoubor()              // jeste musim predtim ten sr zavrit!!
        {
            if (reader != null)
                pocetEnteru = reader.pocetEnteru;
            sr = null;
            while (sr == null && cisloSouboru < soubory.Length)
            {
                try
                {
                    sr = new StreamReader(soubory[cisloSouboru++]);
                }
                catch (IOException)
                {
                    sr = null;
                }
            }
            if (sr != null)
            {
                reader = new WordReader(delimitry, sr, pocetEnteru);
                return reader;
            }
            else
                return null;
        }
        public void zavriSr()
        {
            sr.Close();
        }
    }
    public class WordReader : IWordReader
    {
        TextReader sr;
        char[] delimitry;
        bool hledamBileZnaky = true;
        public int pocetEnteru { get; set; }
        public bool konecSouboru { private set; get; } = false;

        public WordReader(string delimitry, TextReader sr, int pocetEnteru)
        {
            this.delimitry = delimitry.ToCharArray();
            this.sr = sr;
            this.pocetEnteru = pocetEnteru;
        }
        /// <summary>
        /// pokud jsem na konci souboru, vrati to, co tam je (kdyz je to uprostred mezer, muze to byt i {})
        /// pokud jsem na konci slova, vrati slovo
        /// pokud jsem na konci mezery, vrati \n, pokud tam byl mezitim vic nez jeden enter, jinak cte dal a zapisuje do slova
        /// </summary>
        /// <returns></returns>
        public string vratSlovo()
        {
            StringBuilder slovo = new StringBuilder();
            while (true)
            {
                char ch = CtiZnak();
                if (konecSouboru)
                {
                    return slovo.ToString();
                }
                if (!delimitry.Contains(ch) && !hledamBileZnaky)                // ch není bílý znak a jsem uprostřed slova
                {
                    pocetEnteru = 0;
                    sr.Read();
                    slovo.Append(ch);
                }
                else if (delimitry.Contains(ch) && hledamBileZnaky)             // ch je bílý znak a jsem uprostřed mezery
                {
                    sr.Read();
                    if (ch == '\n')
                        pocetEnteru++;
                }
                else
                {                                                               // jsem na konci nebo začátku slova
                    hledamBileZnaky = !hledamBileZnaky;
                    if (hledamBileZnaky)                                        // jsem na konci slova
                    {
                        return slovo.ToString();
                    }
                    else if (pocetEnteru > 1)                                   // konec odstavce
                    {
                        pocetEnteru = 0;
                        return "\n";
                    }
                }
            }
        }
        /// <summary>
        /// podiva se na nasledujici znak, vrati ho (pokud je konec souboru, zapise to do promenne a vrati '0')
        /// </summary>
        /// <returns></returns>
        private char CtiZnak()
        {
            int precteno = sr.Peek();
            if (precteno == -1)
            {
                konecSouboru = true;
                return '0';
            }
            char ch = (char)precteno;
            return ch;
        }
        /// <summary>
        /// preskoci mezery na zacatku prvniho souboru, nastavi sr na prvni spravny soubor
        /// </summary>
        public void zacatekPrvnihoSouboru()
        {
            hledamBileZnaky = false;
            while (true)
            {
                char ch = CtiZnak();
                if (konecSouboru)
                    return;
                if (!delimitry.Contains(ch))
                {
                    return;
                }
                else
                {
                    sr.Read();
                }
            }
        }
    }
    public class MyWriter
    {
        TextWriter writer;
        IFileProcessor fileProcessor;
        IWordReader reader;
        int povolenaDelkaRadku, delkaRadku = 0;
        string slovo;
        string konecRadku, mezera;
        List<string> slovaRadku = new List<string>();
        public MyWriter(TextWriter writer, IFileProcessor fileProcessor, int povolenaDelkaRadku, bool zvyrazneniBilych)
        {
            this.writer = writer;
            this.fileProcessor = fileProcessor;
            this.povolenaDelkaRadku = povolenaDelkaRadku;
            if (zvyrazneniBilych)
            {
                konecRadku = "<-";
                mezera = ".";
            }
            else
            {
                konecRadku = "";
                mezera = " ";
            }
        }
        public void ZarovnejVypis()
        {
            reader = fileProcessor.dalsiSoubor();
            while (true)
            {
                bool konecOdstavce = false;
                slovo = reader.vratSlovo();
                if (slovo == "\n")
                {
                    konecOdstavce = true;
                }
                if (reader.konecSouboru)
                {
                    PosledniSlovo(konecOdstavce);
                    fileProcessor.zavriSr();
                    reader = fileProcessor.dalsiSoubor();
                    if (reader == null)
                    {
                        vypisRadek(slovaRadku, delkaRadku, false, true);
                        return;
                    }
                }
                else
                {
                    if ((slovo.Length + slovaRadku.Count + delkaRadku > povolenaDelkaRadku || konecOdstavce) && slovaRadku.Count > 0)
                    {
                        vypisRadek(slovaRadku, delkaRadku, konecOdstavce, false);
                        slovaRadku.Clear();
                        delkaRadku = 0;
                    }
                    if (!konecOdstavce)
                    {
                        delkaRadku += slovo.Length;
                        slovaRadku.Add(slovo);
                    } 
                }
            }
        }

        private void PosledniSlovo(bool konecOdstavce)
        {
            if (slovo != "" && slovo != "\n")
            {
                if (slovo.Length + slovaRadku.Count + delkaRadku > povolenaDelkaRadku)
                {
                    vypisRadek(slovaRadku, delkaRadku, konecOdstavce, false);
                    slovaRadku.Clear();
                    delkaRadku = 0;
                }
                slovaRadku.Add(slovo);
                delkaRadku += slovo.Length;
            }
        }

        public void vypisRadek(List<string> slovaRadku, int delkaRadku, bool konecOdstavce, bool konecVseho)
        {
            if (slovaRadku.Count > 0)
            {
                writer.Write(slovaRadku[0]);
                if (slovaRadku.Count != 1)
                {
                    int pocetMezer = 1, oJednoVetsi = 0;
                    if (!konecOdstavce && !konecVseho)
                    {
                        pocetMezer = (povolenaDelkaRadku - delkaRadku) / (slovaRadku.Count - 1);
                        oJednoVetsi = (povolenaDelkaRadku - delkaRadku) % (slovaRadku.Count - 1);
                    }

                    for (int i = 1; i < slovaRadku.Count; i++)
                    {
                        int mezery = pocetMezer;
                        if (i <= oJednoVetsi)
                            mezery++;
                        for (int j = 0; j < mezery; j++)
                        {
                            writer.Write(mezera);
                        }
                        writer.Write(slovaRadku[i]);
                    }
                }
            }
            writer.WriteLine(konecRadku);
            if (konecOdstavce)
                writer.WriteLine(konecRadku);
        }
    }
}

/*using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.IO;
using _04zarovnaniViceSouboru;

namespace zarovnaniViceSouboru_testy
{
    [TestClass]
    public class MyWriter_Test
    {
        [TestMethod]
        public void vypisRadek_bezPridavaniMezer()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 43, false);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, false);
            Assert.AreEqual("The rain in Spain falls mainly on the plain.\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_sPridavanimMezer()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 57, false);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, false);
            Assert.AreEqual("The   rain   in   Spain   falls   mainly   on  the  plain.\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_bezMezerKonecOdstavce()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 43, false);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, true, false);
            Assert.AreEqual("The rain in Spain falls mainly on the plain.\r\n\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_sPridavanimMezerKonecOdstavce()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 57, false);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, true, false);
            Assert.AreEqual("The rain in Spain falls mainly on the plain.\r\n\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_bezMezerKonecVseho()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 43, false);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, true);
            Assert.AreEqual("The rain in Spain falls mainly on the plain.\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_sPridavanimMezerKonecVseho()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 57, false);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, true);
            Assert.AreEqual("The rain in Spain falls mainly on the plain.\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_bezMezerKonecOdstavceVseho()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 43, false);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, true);
            Assert.AreEqual("The rain in Spain falls mainly on the plain.\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_sPridavanimMezerKonecOdstavceVseho()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 57, false);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, true);
            Assert.AreEqual("The rain in Spain falls mainly on the plain.\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_BilebezPridavaniMezer()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 43, true);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, false);
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_BilesPridavanimMezer()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 57, true);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, false);
            Assert.AreEqual("The...rain...in...Spain...falls...mainly...on..the..plain.<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_BilebezMezerKonecOdstavce()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 43, true);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, true, false);
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_BilesPridavanimMezerKonecOdstavce()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 57, true);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, true, false);
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_BilebezMezerKonecVseho()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 43, true);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, true);
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_BilesPridavanimMezerKonecVseho()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 57, true);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, true);
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_BilebezMezerKonecOdstavceVseho()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 43, true);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, true);
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void vypisRadek_BilesPridavanimMezerKonecOdstavceVseho()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), null, 57, true);
            myWriter.vypisRadek(new List<string> { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." }, 35, false, true);
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n", sb.ToString());
        }

        [TestMethod]
        public void Zarovnejavypis_jedenSouborBezEnteru()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), new TestFileProcessor(new string [][] { new string[] { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." } }), 57, true);
            myWriter.ZarovnejVypis();
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void Zarovnejavypis_dvaSouboryBezEnteru()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), new TestFileProcessor(new string[][] { new string[] { "The", "rain", "in", "Spain", "falls" }, new string[] { "mainly", "on", "the", "plain." } }), 57, true);
            myWriter.ZarovnejVypis();
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void Zarovnejavypis_dvaSouboryJedenEnter()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), new TestFileProcessor(new string[][] { new string[] { "The", "rain", "in", "Spain", "falls"}, new string[] { "\n", "mainly", "on", "the", "plain." } }), 57, true);
            myWriter.ZarovnejVypis();
            Assert.AreEqual("The.rain.in.Spain.falls<-\r\n<-\r\nmainly.on.the.plain.<-\r\n", sb.ToString());
        }

        [TestMethod]
        public void Zarovnejavypis_dvaSouboryDvaEntery()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), new TestFileProcessor(new string[][] { new string[] { "The", "rain", "in", "Spain", "falls", "\n" }, new string[] { "\n", "mainly", "on", "the", "plain." } }), 57, true);
            myWriter.ZarovnejVypis();
            Assert.AreEqual("The.rain.in.Spain.falls<-\r\n<-\r\nmainly.on.the.plain.<-\r\n", sb.ToString());
        }

        [TestMethod]
        public void Zarovnejavypis_jedenSouborRozdelit()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), new TestFileProcessor(new string[][] { new string[] { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." } }), 17, true);
            myWriter.ZarovnejVypis();
            Assert.AreEqual("The.rain.in.Spain<-\r\nfalls..mainly..on<-\r\nthe.plain.<-\r\n", sb.ToString());
        }
        [TestMethod]
        public void Zarovnejavypis_enteryNaZacatku()
        {
            StringBuilder sb = new StringBuilder();
            MyWriter myWriter = new MyWriter(new StringWriter(sb), new TestFileProcessor(new string[][] { new string[] { "\n", "\n", "\n", "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." } }), 57, true);
            myWriter.ZarovnejVypis();
            Assert.AreEqual("The.rain.in.Spain.falls.mainly.on.the.plain.<-\r\n", sb.ToString());
        }
    }


    [TestClass]
    public class TestWordReader : IWordReader
    {
        int cisloSlova = 0;
        string[] slova;
        public int pocetEnteru { get; set; }
        public bool konecSouboru { private set; get; } = false;

        public TestWordReader(string[] slova)
        {
            this.slova = slova;
        }

        public string vratSlovo()
        {
            if (cisloSlova == slova.Length - 1)
            {
                konecSouboru = true;
            }
            return slova[cisloSlova++];
        }

        public void zacatekPrvnihoSouboru()
        {
            while (slova[cisloSlova] == "\n")
                cisloSlova++;
        }
    }

    [TestClass]
    public class TestFileProcessor : IFileProcessor
    {
        string[] slova;
        string[][] soubory;
        int cisloSouboru = 0;
        public TestFileProcessor(string[][] soubory)
        {
            this.soubory = soubory;
        }
        public IWordReader dalsiSoubor()
        {
            if (cisloSouboru < soubory.Length)
            {
                slova = soubory[cisloSouboru++];
                return new TestWordReader(slova);
            }
            return null;
        }

        public void zavriSr()
        {
        }

    }
}
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.IO;
using _04zarovnaniViceSouboru;

namespace zarovnaniViceSouboru_testy
{
    [TestClass]
    public class WordReader_Test
    {
        [TestMethod]
        public void vratSlovo_SingleLineWithoutTerminatingNewLine()
        {
            var words = new[] { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." };
            var reader = new WordReader(" \n\t\r", new StringReader("The rain in Spain falls mainly on the plain."), 0);

            foreach (var word in words)
            {
                Assert.AreEqual(word, reader.vratSlovo());
            }

            Assert.AreEqual(reader.konecSouboru, true);
            Assert.AreEqual(reader.pocetEnteru, 0);
        }
        [TestMethod]
        public void vratSlovo_SingleLineIncludingTerminatingNewLine()
        {
            var words = new[] { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain.", "" };
            var reader = new WordReader(" \n\t\r", new StringReader("The rain in Spain falls mainly on the plain.\n"), 0);

            foreach (var word in words)
            {
                Assert.AreEqual(word, reader.vratSlovo());
            }

            Assert.AreEqual(reader.konecSouboru, true);
            Assert.AreEqual(reader.pocetEnteru, 1);
        }

        [TestMethod]
        public void vratSlovo_SingleLineWithManySpacesIncludingTerminatingNewLine()
        {
            var words = new[] { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain.", ""};
            var reader = new WordReader(" \n\t\r", new StringReader("   The rain    in \tSpain\tfalls\t\t\tmainly on the plain.\n"), 0);

            foreach (var word in words)
            {
                Assert.AreEqual(word, reader.vratSlovo());
            }

            Assert.AreEqual(reader.konecSouboru, true);
            Assert.AreEqual(reader.pocetEnteru, 1);
        }

        [TestMethod]
        public void vratSlovo_MutipleLinesWithoutTerminatingNewLine()
        {
            var words = new[] { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain." };
            var reader = new WordReader(" \n\t\r", new StringReader("The rain in\nSpain falls mainly\non the plain."), 0);

            foreach (var word in words)
            {
                Assert.AreEqual(word, reader.vratSlovo());
            }

            Assert.AreEqual(reader.konecSouboru, true);
            Assert.AreEqual(reader.pocetEnteru, 0);
        }

        [TestMethod]
        public void vratSlovo_MutipleLinesIncludingTerminatingNewLine()
        {
            var words = new[] { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain.", ""};
            var reader = new WordReader(" \n\t\r", new StringReader("The rain in\nSpain falls mainly\non the plain.\n"), 0);

            foreach (var word in words)
            {
                Assert.AreEqual(word, reader.vratSlovo());
            }

            Assert.AreEqual(reader.konecSouboru, true);
            Assert.AreEqual(reader.pocetEnteru, 1);
        }

        [TestMethod]
        public void vratSlovo_MutipleLinesWithManySpacesIncludingTerminatingNewLine()
        {
            var words = new[] { "The", "rain", "in", "Spain", "falls", "mainly", "on", "the", "plain.", ""};
            var reader = new WordReader(" \n\t\r", new StringReader("The rain      in   \n   Spain\tfalls\t\t\tmainly\non the plain.    \n"), 0);

            foreach (var word in words)
            {
                Assert.AreEqual(word, reader.vratSlovo());
            }

            Assert.AreEqual(reader.konecSouboru, true);
            Assert.AreEqual(reader.pocetEnteru, 1);
        }

        [TestMethod]
        public void vratSlovo_MutipleIncludingEmptyLinesWithManySpacesIncludingTerminatingNewLine()
        {
            var words = new[] { "The", "rain", "in", "\n", "Spain", "falls", "mainly", "on", "the", "plain.", ""};
            var reader = new WordReader(" \n\t\r", new StringReader("The rain      in   \n     \n\n\n  Spain\tfalls\t\t\tmainly\non the plain.    \n"), 0);

            foreach (var word in words)
            {
                Assert.AreEqual(word, reader.vratSlovo());
            }
            Assert.AreEqual(reader.konecSouboru, true);
            Assert.AreEqual(reader.pocetEnteru, 1);
        }

        [TestMethod]
        public void vratSlovo_OnlyWhitecharacters()
        {
            var words = new[] { "" };
            var reader = new WordReader(" \n\t\r", new StringReader("   \t\n  \n    \n\n\n    \n \t\t\t  \n"), 0);

            foreach (var word in words)
            {
                Assert.AreEqual(word, reader.vratSlovo());
            }
            Assert.AreEqual(reader.konecSouboru, true);
            Assert.AreEqual(reader.pocetEnteru, 7);
        }
        [TestMethod]
        public void zacatekPrvnihoSouboru_hnedSlova()
        {
            var reader = new WordReader(" \n\t\r", new StringReader("The rain in Spain falls mainly on the plain."), 0);
            reader.zacatekPrvnihoSouboru();
            Assert.AreEqual(reader.konecSouboru, false);
            Assert.AreEqual(reader.pocetEnteru, 0);
            Assert.AreEqual(reader.vratSlovo(), "The");
        }
        [TestMethod]
        public void zacatekPrvnihoSouboru_Mezery()
        {
            var reader = new WordReader(" \n\t\r", new StringReader("           \t\t       The rain in Spain falls mainly on the plain."), 0);
            reader.zacatekPrvnihoSouboru();
            Assert.AreEqual(reader.konecSouboru, false);
            Assert.AreEqual(reader.pocetEnteru, 0);
            Assert.AreEqual(reader.vratSlovo(), "The");
        }
        [TestMethod]
        public void zacatekPrvnihoSouboru_newLines()
        {
            var reader = new WordReader(" \n\t\r", new StringReader("\n     \t\n   \t\tThe rain in Spain falls mainly on the plain."), 0);
            reader.zacatekPrvnihoSouboru();
            Assert.AreEqual(reader.konecSouboru, false);
            Assert.AreEqual(reader.pocetEnteru, 0);
            Assert.AreEqual(reader.vratSlovo(), "The");
        }
        [TestMethod]
        public void zacatekPrvnihoSouboru_bileZnaky()
        {
            var reader = new WordReader(" \n\t\r", new StringReader("   \t\n  \n    \n\n\n    \n \t\t\t  \n"), 0);
            reader.zacatekPrvnihoSouboru();
            Assert.AreEqual(reader.konecSouboru, true);
            Assert.AreEqual(reader.pocetEnteru, 0);
            Assert.AreEqual(reader.vratSlovo(), "");
        }
    }
}
*/
