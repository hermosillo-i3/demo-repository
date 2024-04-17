/*
 * NumerosALetras.js
 * The MIT License (MIT)
 *
 * Copyright (c) 2016 Daniel M. Spiridione
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the 'Software'), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * @author Daniel M. Spiridione (info@daniel-spiridione.com.ar)
 */

const currencyObject = {
   'mxn': {
      letrasCentavos: '',
      letrasMonedaPlural: 'Pesos',
      letrasMonedaSingular: 'Peso',
      letrasMonedaCentavoPlural: '/100 M.N.',
      letrasMonedaCentavoSingular: '/100 M.N.',
   },
   'usd': {
      letrasCentavos: '',
      letrasMonedaPlural: 'Dólares',
      letrasMonedaSingular: 'Dólar',
      letrasMonedaCentavoPlural: '/100 Dlls',
      letrasMonedaCentavoSingular: '/100 Dlls',
   },
};

function units(num) {
   switch (num) {
      case 1:
         return 'Un';
      case 2:
         return 'Dos';
      case 3:
         return 'Tres';
      case 4:
         return 'Cuatro';
      case 5:
         return 'Cinco';
      case 6:
         return 'Seis';
      case 7:
         return 'Siete';
      case 8:
         return 'Ocho';
      case 9:
         return 'Nueve';
      default:
         return '';
   }
}

function test(strSin, numUnidades) {
   console.log('strSin: ', strSin);
}

function tensY(strSin, numUnidades) {
   if (numUnidades > 0) {
      return strSin + ' y ' + units(numUnidades);
   }

   return strSin;
}

function tens(num) {
   const numDecena = Math.floor(num / 10);
   const numUnidad = num - numDecena * 10;

   switch (numDecena) {
      case 1:
         switch (numUnidad) {
            case 0:
               return 'Diez';
            case 1:
               return 'Once';
            case 2:
               return 'Doce';
            case 3:
               return 'Trece';
            case 4:
               return 'Catorce';
            case 5:
               return 'Quince';
            default:
               return 'Dieci' + units(numUnidad).toLowerCase();
         }
      case 2:
         switch (numUnidad) {
            case 0:
               return 'Veinte';
            default:
               return 'Veinti' + units(numUnidad).toLowerCase();
         }
      case 3:
         return tensY('Treinta', numUnidad);
      case 4:
         return tensY('Cuarenta', numUnidad);
      case 5:
         return tensY('Cincuenta', numUnidad);
      case 6:
         return tensY('Sesenta', numUnidad);
      case 7:
         return tensY('Setenta', numUnidad);
      case 8:
         return tensY('Ochenta', numUnidad);
      case 9:
         return tensY('Noventa', numUnidad);
      case 0:
         return units(numUnidad);
      default:
         return '';
   }
}

function hundreds(num) {
   const numCentenas = Math.floor(num / 100);
   const numDecenas = num - numCentenas * 100;

   switch (numCentenas) {
      case 1:
         if (numDecenas > 0) {
            return 'Ciento ' + tens(numDecenas);
         }
         return 'Cien';
      case 2:
         return 'Doscientos ' + tens(numDecenas);
      case 3:
         return 'Trescientos ' + tens(numDecenas);
      case 4:
         return 'Cuatrocientos ' + tens(numDecenas);
      case 5:
         return 'Quinientos ' + tens(numDecenas);
      case 6:
         return 'Seiscientos ' + tens(numDecenas);
      case 7:
         return 'Setecientos ' + tens(numDecenas);
      case 8:
         return 'Ochocientos ' + tens(numDecenas);
      case 9:
         return 'Novecientos ' + tens(numDecenas);
      default:
         return tens(numDecenas);
   }
}

function section(num, divisor, strSingular, strPlural) {
   const numCientos = Math.floor(num / divisor);
   const numResto = num - numCientos * divisor;

   let letras = '';

   if (numCientos > 0) {
      if (numCientos > 1) {
         letras = hundreds(numCientos) + ' ' + strPlural;
      } else {
         letras = strSingular;
      }
   }

   if (numResto > 0) {
      letras += '';
   }

   return letras;
}

function thousands(num) {
   const divisor = 1000;
   const numCientos = Math.floor(num / divisor);
   const numResto = num - numCientos * divisor;
   const strMiles = section(num, divisor, 'Un Mil', 'Mil');
   const strCentenas = hundreds(numResto);

   if (strMiles === '') {
      return strCentenas;
   }

   return (strMiles + ' ' + strCentenas).trim();
}

function millions(num) {
   const divisor = 1000000;
   const numCientos = Math.floor(num / divisor);
   const numResto = num - numCientos * divisor;
   const strMillones = section(num, divisor, 'Un Millón de', 'Millones de');
   const strMiles = thousands(numResto);

   if (strMillones === '') {
      return strMiles;
   }

   return (strMillones + ' ' + strMiles).trim();
}

function convertNumberToLetter(num, currency = '') {
   const currencyInfo = currencyObject[currency.toLowerCase()] ?? currencyObject['mxn'];
   const data = {
      numero: num,
      enteros: Math.floor(num),
      centavos: Math.round(num * 100) - Math.floor(num) * 100,
      ...currencyInfo,
   };

   if (data.centavos >= 0) {
      data.letrasCentavos = function() {
         if (data.centavos >= 1 & data.centavos <= 9) {
            return 'con ' + '0' + data.centavos + data.letrasMonedaCentavoSingular;
         }

         if (data.centavos === 0) {
            return '00' + data.letrasMonedaCentavoSingular;
         }

         return 'con ' + data.centavos + data.letrasMonedaCentavoPlural;
      }();
   }

   if (data.enteros === 0) {
      return ('Cero ' + data.letrasMonedaPlural + ' ' + data.letrasCentavos).trim();
   }

   if (data.enteros === 1) {
      return (millions(data.enteros) + ' ' + data.letrasMonedaSingular + ' ' + data.letrasCentavos).trim();
   }

   return (millions(data.enteros) + ' ' + data.letrasMonedaPlural + ' ' + data.letrasCentavos).trim();
}

module.exports = {
   convertNumberToLetter,
};
