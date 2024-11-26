import type { ThemeOptions } from '@mui/material';
import { createTheme } from '@mui/material';

const cssVars = {
    colors: {
      cerulean: '#01A1B7',
      teal: '#017788',
  
      ceruleanHover: 'rgba(1, 161, 183, 0.1)',
  
      brightYellow: '#FF9F1C',
      sienna: '#C46C2A',
      spanishOrange: '#EB7100',
      textWarning: '#C67000',
  
      richBlack: '#050404',
      jetBlack: '#322F2F',
      charlestonGreen: '#2E282A',
      textSuccess: '#3C7107',
  
      lightGray: '#D3D3D3',
      whiteSmoke: '#F5F5F5',
      white: '#FFFFFF',
  
      stone: '#8A8889',
      slate: '#B3B4B3', // used for disabled
      concrete: '#B8B2A9',
      gainsboro: '#E0E0E0',
  
      roseMadder: '#E71D36', // used for errors
      lightError: '#FAE5E8',
      palmLeaf: '#6CA03B', // used for success
      green: '#76B041',
      darkCyan: '#024959',
    },
  
    fontWeights: {
      light: 300,
      normal: 400,
      semibold: 600,
      bold: 700,
    },
  };

const {cerulean, textSuccess, slate, textWarning, teal} = cssVars.colors;

const theme: ThemeOptions = {
  typography: {
    fontFamily: 'Open Sans, sans-serif',
    fontSize: 12,
    fontWeightLight: 'var(--font-weight-light)',
    fontWeightRegular: 'var(--font-weight-normal)',
    fontWeightMedium: 'var(--font-weight-semibold)',
    fontWeightBold: 'var(--font-weight-bold)',
    htmlFontSize: 12,
    // body3: {
    //   fontWeight: 400,
    //   fontSize: '14px',
    //   letterSpacing: '0.25px',
    //   lineHeight: '24px',
    // },
    // body4: {
    //   fontWeight: 400,
    //   fontSize: '12px',
    //   letterSpacing: '0.25px',
    //   lineHeight: '26px',
    // },
    // noContent: {
    //   fontWeight: 600,
    //   fontSize: '16px',
    //   letterSpacing: '0',
    // },
    // value: {
    //   fontWeight: 600,
    //   fontSize: '14px',
    //   letterSpacing: '0.15px',
    // },
    // label: {
    //   fontWeight: 400,
    //   fontSize: '12px',
    //   letterSpacing: '0.15px',
    // },
    // helper: {
    //   fontWeight: 400,
    //   fontSize: '10px',
    //   letterSpacing: '0.4px',
    // },
  },
  palette: {
    primary: {
      main: teal,
    },
    secondary: {
      main: cerulean,
    },
    text: {
      secondary: slate,
      disabled: slate,
    },
    success: {
      main: textSuccess,
    },
    error: {
      main: textWarning,
    },
  },
  components: {
    MuiTypography: {
      styleOverrides: {
        h1: {
          fontWeight: 300,
          fontSize: '60px',
          letterSpacing: '-0.5px',
        },
        h2: {
          fontWeight: 400,
          fontSize: '48px',
          letterSpacing: 0,
        },
        h3: {
          fontWeight: 400,
          fontSize: '36px',
          letterSpacing: '0.25px',
        },
        h4: {
          fontWeight: 400,
          fontSize: '30px',
          letterSpacing: '0.3px',
        },
        h5: {
          fontWeight: 400,
          fontSize: '24px',
          letterSpacing: 0,
        },
        h6: {
          fontWeight: 600,
          fontSize: '18px',
          letterSpacing: '0.15px',
        },
        subtitle1: {
          fontWeight: 400,
          fontSize: '16px',
          letterSpacing: '0.15px',
        },
        subtitle2: {
          fontWeight: 600,
          fontSize: '14px',
          letterSpacing: '0.1px',
        },
        body1: {
          fontWeight: 400,
          fontSize: '16px',
          letterSpacing: '0.5px',
          lineHeight: '28px',
        },
        body2: {
          fontWeight: 400,
          fontSize: '14px',
          letterSpacing: '0.25px',
          lineHeight: '26px',
        },
        button: {
          fontWeight: 600,
          fontSize: '14px',
          letterSpacing: '1.25px',
        },
        caption: {
          fontWeight: 400,
          fontSize: '14px',
          letterSpacing: '0.5px',
        },
        overline: {
          fontWeight: 600,
          fontSize: '14px',
          letterSpacing: '1.25px',
        },
      },
    },
    MuiInput: {
      styleOverrides: {
        root: {
          borderColor: 'var(--color-lightGray)',
          color: 'var(--color-jetBlack)',
          fontSize: 'var(--size-input)',
          '&.Mui-error:before': {
            borderBottomColor: 'var(--color-textWarningYellow)',
          },
          '&.Mui-error:after': {
            borderBottomColor: 'var(--color-textWarningYellow)',
          },
        },
        underline: {
          '&:hover:not(.Mui-disabled):not(.MuiInput-multiline):before': {
            borderBottom: '2px solid var(--color-teal)',
          },
          '&::before': {
            borderColor: 'var(--color-stone)',
          },
        },
      },
    },
    MuiOutlinedInput: {
      styleOverrides: {
        root: {
          '&:hover:not(.Mui-disabled):not(.Mui-error):not(.Mui-focused) .MuiOutlinedInput-notchedOutline':
            {
              border: '2px solid var(--color-teal)',
            },
        },
        notchedOutline: {
          borderColor: 'var(--color-lightGray)',
          '& legend': {
            fontSize: '12px',
          },
        },
      },
    },
    MuiSelect: {
      styleOverrides: {
        select: {
          height: '20px',
          lineHeight: '24px',
        },
      },
    },
    MuiFormHelperText: {
      styleOverrides: {
        root: {
          display: 'flex',
          alignItems: 'center',
          color: 'var(--color-jetBlack)',
          fontSize: 'var(--size-label)',
          fontWeight: 'var(--font-weight-semibold)',
          lineHeight: 'var(--size-label)',
          height: '18px',
          '&.Mui-error': {
            '& .MuiSvgIcon-root.MuiSvgIcon-colorError': {
              color: 'var(--color-textWarningYellow)',
            },
            '& .MuiTypography-root.MuiTypography-body1': {
              color: 'var(--color-textWarningYellow)',
            },
          },
        },
        contained: {
          marginLeft: 0,
          marginRight: 0,
        },
      },
    },
    MuiTooltip: {
      styleOverrides: {
        tooltip: {
          fontSize: '12px',
          backgroundColor: 'var(--color-jetBlack)',
        },
        arrow: {
          color: 'var(--color-jetBlack)',
        },
      },
    },
    MuiFormLabel: {
      styleOverrides: {
        root: {
          fontSize: 'var(--size-label)',
          color: 'var(--color-jetBlack)',
        },
        asterisk: {
          display: 'none',
        },
      },
    },
    MuiInputLabel: {
      styleOverrides: {
        root: {
          fontSize: 'var(--size-label)',
          color: 'var(--color-granite)',
          transform: 'translate(0, 1.5px) scale(1)',
          '&.Mui-error': {
            color: 'var(--color-textWarningYellow)',
          },
        },
        outlined: {
          '&.MuiInputLabel-shrink': {
            transform: 'translate(14px, -9px) scale(1)',
          },
        },
        shrink: {
          transform: 'scale(1)',
        },
        asterisk: {
          display: 'none',
        },
      },
    },
    MuiModal: {
      defaultProps: {
        disableEnforceFocus: true,
      },
    },
    MuiButton: {
      styleOverrides: {
        outlined: {
          '&.Mui-disabled': {
            border: '2px solid rgba(0, 0, 0, 0.12)',
          },
        },
      },
    },
    MuiIconButton: {
      styleOverrides: {
        root: {
          '&:hover': {
            backgroundColor: 'transparent',
          },
        },
      },
    },
    MuiStepIcon: {
      styleOverrides: {
        root: {
          '&.Mui-active': {
            color: textWarning,
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          display: 'grid',
          gridTemplateColumns: '1fr',
          gridTemplateRows: 'auto 1fr auto',
          gridTemplateAreas: "'header' 'content' 'footer'",
        },
      },
    },
    MuiCardHeader: {
      styleOverrides: {
        root: {
          gridArea: 'header',
          // Note: This height should be the same as .MuiCardHeader-action:height
          height: '48px',
          borderBottom: '1px solid var(--color-button-disabled)',

          /**
           * Note: These overrides alter the default theme styling when the
           * class 'custom-subheader' is included on any <CardHeader /> component
           */
          '&.custom-subheader': {
            height: '74px',
            paddingTop: '0',
            paddingBottom: '0',
            paddingLeft: '0',
          },
          '&.custom-subheader .MuiCardHeader-title': {
            paddingTop: '8px',
            paddingBottom: '8px',
            paddingLeft: '16px',
            borderBottom: '1px solid var(--color-lightGray)',
          },
          '&.custom-subheader .MuiCardHeader-action': {
            height: '48px',
            marginTop: '0px',
            borderBottom: '1px solid var(--color-lightGray)',
          },
        },
        //Note: MUI defaults this to an h5
        title: {
          whiteSpace: 'nowrap',
          overflow: 'hidden',
        },
        //Note: MUI defaults this to an h6
        subheader: {
          borderTop: '1px solid var(--color-lightGray)',
          whiteSpace: 'nowrap',
          overflow: 'hidden',
          paddingTop: '2px',
          paddingBottom: '2px',
          paddingLeft: '16px',
        },
        action: {
          // Note: This height should be the same as .MuiCardHeader-root:height
          height: '48px',
          //Note: Negative margin to account for the default padding on MuiCardHeader.root
          marginTop: '-16px',
          marginRight: '-16px',
          display: 'flex',
          alignItems: 'center',

          '& .MuiTypography-root': {
            color: textWarning,
            fontSize: '14px',
            fontWeight: 'var(--font-weight-bold)',
          },

          '& .MuiSvgIcon-root': {
            color: 'var(--color-teal)',
          },
        },
      },
    },
    MuiCardContent: {
      styleOverrides: {
        root: {
          gridArea: 'content',
          overflowY: 'auto',
          overflowX: 'hidden',

          // Note: Removes MUI default padding
          '&:last-child': {
            paddingTop: 0,
            paddingBottom: 0,
            paddingLeft: 0,
            paddingRight: 0,
          },
        },
      },
    },
    MuiCardActions: {
      styleOverrides: {
        root: {
          gridArea: 'footer',
          padding: '5px',
          borderTop: '1px solid var(--color-button-disabled)',
        },
      },
    },
    MuiInputBase: {
      styleOverrides: {
        root: {
          '& .MuiButtonBase-root.MuiIconButton-root': {
            color: 'var(--color-darkTeal)',
          },
          '&:hover:not(.Mui-disabled)': {
            '& .MuiButtonBase-root.MuiIconButton-root': {
              color: 'var(--color-darkTeal)',
            },
          },
          '&.Mui-focused': {
            '& .MuiButtonBase-root.MuiIconButton-root': {
              color: 'var(--color-darkTeal)',
            },
          },
        },
        input: {
          fontSize: '14px',
          fontWeight: 'var(--font-weight-semibold)',
          color: 'var(--color-jetBlack)',
        },
      },
    },
    MuiCheckbox: {
      styleOverrides: {
        root: {
          padding: '6px 8px 6px 0px',
          color: 'var(--color-darkTeal)',
          '&.Mui-checked': {
            color: 'var(--color-darkTeal)',
          },
          '&.Mui-disabled': {
            color: 'var(--color-stone)',
          },
        },
      },
    },
    MuiFormControlLabel: {
      styleOverrides: {
        label: {
          color: 'var(--color-jetBlack)',
          '&.Mui-disabled': {
            color: 'var(--color-stone)',
          },
        },
      },
    },
    MuiChip: {
      styleOverrides: {
        root: {
          '& .MuiChip-label': {
            fontWeight: 'var(--font-weight-semibold)',
            fontSize: 'var(--size-input)',
          },
        },
      },
    },
    MuiListItemText: {
      styleOverrides: {
        root: {
          '& .MuiListItemText-primary': {
            color: 'var(--color-jetBlack)',
            fontWeight: 'var(--font-weight-semibold)',
          },
          '& .MuiListItemText-secondary': {
            color: 'var(--color-granite)',
          },
        },
      },
    },
  },
};

export const muiTheme = createTheme(theme);
