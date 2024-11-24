import { AppBar, Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Toolbar, Typography } from '@mui/material';
import * as React from 'react';
import ActivityListItem from '../components/ActivityListItem';
import FacilityRow from '../components/FacilityRow';
import type { Activity, Facility } from '../types/types.ts';
//import { useFacilitiesQuery } from '../queries/useFacilitiesQuery';

const Dashboard = () => {
    // const { data: facilities } = useFacilitiesQuery("9b5a1a77-a5b3-4b86-9066-99a7a30b8ac3");
    const facilities : Facility[] = [{
		name: "F1",
		facilityId: "123"
	},
	{
		name: "F2",
		facilityId: "456"		
	}];
    // const { data: updates } = useActivityQuery("9b5a1a77-a5b3-4b86-9066-99a7a30b8ac3");
    const updates : Activity[] = [{
		name: "Event A",
		date: new Date()
	},
	{
		name: "Event B",
		date: new Date()	
	}];

    return (
        <>
            <Box
				sx={{
					display: 'flex',
					flexDirection: 'row',
					maxHeight: '100%',
					height: '100%',
					width: '100%',
				}}
            >
                <AppBar
                    position="fixed"
                    sx={{
                        backgroundColor: 'green'
                    }}
                    elevation={1}
                >
                    <Toolbar>
                        <Box
                            sx={{
                                display: 'flex',
                                alignItems: 'center',
                            }}
                        >
                            <Typography variant="h6">
                                SenseRx
                            </Typography>
                        </Box>
                    </Toolbar>
                </AppBar> 
                <Box
                    sx={{
                        mt: 6,
                        p: 2,
                        height: '100%',
                        flex: 1,
                    }}
                >
                    <Box sx={{ my: 2 }}>
                        <Typography variant="h6">Facilities</Typography>
                    </Box>
                    <TableContainer component={Paper} sx={{maxWidth: 600}}>
                        <Table>
                            <TableHead>
                                <TableRow>
                                    <TableCell sx={{ fontWeight: 800}}>Name</TableCell>
                                    <TableCell sx={{ fontWeight: 800}}>Id</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {facilities &&
                                    facilities!.map((facility) => (
                                        <FacilityRow
                                            key={facility.facilityId}
                                            facility={facility}
                                        />
                                    ))}
                            </TableBody>
                        </Table>
                    </TableContainer>
                    <Box sx={{ mt: 5, mb: 2 }}>
                        <Typography variant="h6">Updates</Typography>                        
                    </Box>
                    <Box sx={{
                        display: 'flex',
                        flexDirection: 'column',
                    }}>
                    {updates &&
                        updates!.map((update) => (
                            <ActivityListItem
                                key={update.name + '_' + update.date.toDateString()}
                                activity={update}
                            />
                        ))}
                    </Box>
                </Box>   
            </Box>
        </>       
    )
};

export default Dashboard;
