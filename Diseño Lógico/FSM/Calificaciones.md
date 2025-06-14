## Calificaciones y Correcciones: 

- Galdeman 8.0: 
    - El contador tiene 32 bits cuando 8 son suficiente (como máximo hay 200 apariciones de la palabra "casa ")

    - Revisar el uso de parameters dentro del módulo. En ese caso se remoienda usar "localparam" que se utilizan como constantes en el diseño. En cambio, los parámetros se utilizan para hacer un diseño configurable y pueden ser sobreescritos al instanciar el módulo (por ejemplo para definir el número de bits de una entrada o salida)

